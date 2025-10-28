using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;
using Microsoft.AspNetCore.Builder.Extensions;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(JobConnectDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;

            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential
                        .FromFile("serviceAccountKey.json")
                });
            }
        }

        /// <summary>
        /// Đăng ký tài khoản mới
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (await _context.Users.AnyAsync(u => u.Email == model.Email))
                return BadRequest(new { message = "Email đã tồn tại" });

            // Lấy/khởi tạo role
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == model.RoleName);
            if (role == null)
            {
                role = new Role
                {
                    IdRole = Guid.NewGuid().ToString(),
                    RoleName = model.RoleName,
                    Description = $"Auto-created role: {model.RoleName}"
                };
                _context.Roles.Add(role);
                await _context.SaveChangesAsync();
            }

            // Chọn IdUser: ưu tiên AppwriteUserId để mapping 1-1 với Appwrite
            var idUser = string.IsNullOrWhiteSpace(model.AppwriteUserId)
                ? $"user{Guid.NewGuid():N}"
                : model.AppwriteUserId!.Trim();

            // Chuẩn hóa phone (đề phòng client chưa chuẩn hóa)
            string phone = NormalizeToE164(model.PhoneNumber);

            using var tx = await _context.Database.BeginTransactionAsync();

            try
            {
                var user = new User
                {
                    IdUser = idUser,
                    UserName = model.UserName,
                    Email = model.Email,
                    PhoneNumber = phone,
                    Password = BCrypt.Net.BCrypt.HashPassword(model.Password),
                    IdRole = role.IdRole,
                    AccountStatus = role.RoleName.Equals("Recruiter", StringComparison.OrdinalIgnoreCase) ? "pending" : "active",
                    AvatarUrl = "/images/logo.png",
                    SocialLogin = null,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    Gender = "other",
                    Address = null,
                    DateOfBirth = null
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                // nếu là Candidate → tạo candidate_info mặc định ===
                if (role.RoleName.Equals("Candidate", StringComparison.OrdinalIgnoreCase))
                {
                    var existed = await _context.CandidateInfo.FindAsync(user.IdUser);
                    if (existed == null)
                    {
                        var ci = new CandidateInfo
                        {
                            IdUser = user.IdUser,
                            WorkPosition = null,
                            ExperienceYears = null,
                            Skills = null,
                            FreeTime = null,
                            PortfolioUrl = null
                        };
                        _context.CandidateInfo.Add(ci);
                        await _context.SaveChangesAsync();
                    }
                }

                await tx.CommitAsync();

                var result = new
                {
                    IdUser = user.IdUser,
                    Message = "Đăng ký thành công",
                    CandidateInfoCreated = role.RoleName.Equals("Candidate", StringComparison.OrdinalIgnoreCase)
                };

                return CreatedAtAction(nameof(GetById), new { id = user.IdUser }, result);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                return StatusCode(500, new { message = "Đăng ký thất bại", detail = ex.Message });
            }
        }

        // Helper chuẩn hóa E.164 (VN)
        private static string NormalizeToE164(string? raw)
        {
            if (string.IsNullOrWhiteSpace(raw)) return "";
            var trimmed = raw.Trim();
            var digits = new System.Text.StringBuilder();
            foreach (var ch in trimmed) if (char.IsDigit(ch)) digits.Append(ch);

            if (trimmed.StartsWith("+"))
            {
                var number = "+" + digits.ToString();
                return number.Length <= 16 ? number : number[..16];
            }
            if (trimmed.StartsWith("0"))
            {
                var s = digits.ToString();
                if (s.StartsWith("0")) s = s[1..];
                var number = "+84" + s;
                return number.Length <= 16 ? number : number[..16];
            }
            if (digits.Length > 0)
            {
                var number = "+" + digits.ToString();
                return number.Length <= 16 ? number : number[..16];
            }
            return "";
        }


        /// <summary>
        /// Lấy thông tin user theo IdUser
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.IdUser == id);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy user" });

            var vm = new UserDto
            {
                IdUser = user.IdUser,
                UserName = user.UserName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                IdRole = user.IdRole,
                AccountStatus = user.AccountStatus,
                AvatarUrl = user.AvatarUrl,
                SocialLogin = user.SocialLogin,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt,
                Gender = user.Gender,
                Address = user.Address,
                DateOfBirth = user.DateOfBirth,
                Role = new Role
                {
                    IdRole = user.Role.IdRole,
                    RoleName = user.Role.RoleName,
                    Description = user.Role.Description
                }
            };

            return Ok(vm);
        }

        /// <summary>
        /// Đăng nhập và nhận JWT
        /// </summary>
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Include Role khi query User
            var user = await _context.Users
                .Include(u => u.Role) // Join với bảng Roles
                .FirstOrDefaultAsync(u => u.Email == model.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(model.Password, user.Password))
                return Unauthorized(new { message = "Thông tin đăng nhập không hợp lệ" });

            if (user.Role == null)
                return StatusCode(500, new { message = "Không tìm thấy thông tin vai trò cho người dùng" });

            var token = GenerateJwtToken(user);

            var response = new AuthResponseDTO
            {
                Token = token,
                User = new User
                {
                    IdUser = user.IdUser,
                    UserName = user.UserName,
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    Password = BCrypt.Net.BCrypt.HashPassword(model.Password),
                    IdRole = user.IdRole,
                    AccountStatus = user.AccountStatus,
                    AvatarUrl = user.AvatarUrl,
                    SocialLogin = user.SocialLogin,
                    CreatedAt = user.CreatedAt,
                    UpdatedAt = user.UpdatedAt,
                    Gender = user.Gender,
                    Address = user.Address,
                    DateOfBirth = user.DateOfBirth,
                    Role = new Role
                    {
                        IdRole = user.Role.IdRole,
                        RoleName = user.Role.RoleName,
                        Description = user.Role.Description
                    }
                }
            };

            return Ok(response);
        }

        [HttpPost("social-login"), AllowAnonymous]
        public async Task<IActionResult> SocialLogin([FromBody] SocialLoginDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Verify Appwrite JWT by calling /account with the JWT as Bearer
            var verify = await VerifyAppwriteJwtAsync(model.IdToken);
            if (!verify.success)
            {
                return BadRequest($"Invalid Appwrite token: {verify.error}");
            }

            var email = string.IsNullOrWhiteSpace(model.Email) ? (string.IsNullOrWhiteSpace(verify.email) ? $"{verify.userId}@appwrite.local" : verify.email!.Trim()) : model.Email.Trim();
            var name = string.IsNullOrWhiteSpace(model.Name) ? (string.IsNullOrWhiteSpace(verify.name) ? "Google User" : verify.name!.Trim()) : model.Name.Trim();

            var requestedRoleName = string.IsNullOrWhiteSpace(model.RoleName) ? "Candidate" : model.RoleName.Trim();
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == requestedRoleName);
            if (role == null)
            {
                role = new Role
                {
                    IdRole = Guid.NewGuid().ToString(),
                    RoleName = requestedRoleName,
                    Description = requestedRoleName == "Recruiter" ? "Nhà tuyển dụng" : "Ứng viên"
                };
                _context.Roles.Add(role);
                await _context.SaveChangesAsync();
            }

            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.IdUser == verify.userId);

            if (user == null)
            {
                try
                {
                    user = new User
                    {
                        IdUser = verify.userId!,
                        UserName = string.IsNullOrWhiteSpace(name) ? "Google User" : name,
                        Email = string.IsNullOrWhiteSpace(email) ? $"{verify.userId}@appwrite.local" : email,
                        PhoneNumber = null,
                        Password = null,
                        IdRole = role.IdRole,
                        AccountStatus = "active",
                        AvatarUrl = verify.avatar,
                        SocialLogin = "Google",
                        Gender = "other",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();
                }
                catch (Exception ex)
                {
                    return StatusCode(500, $"Save user failed: {ex.Message}");
                }
            }

            if (requestedRoleName.Equals("Recruiter", StringComparison.OrdinalIgnoreCase))
            {
                var recInfo = await _context.RecruiterInfo.FindAsync(user.IdUser);
                if (recInfo == null)
                {
                    try
                    {
                        var company = new Company
                        {
                            IdCompany = Guid.NewGuid().ToString(),
                            CompanyName = "",
                            TaxCode = null,
                            Address = null,
                            Description = null,
                            LogoCompany = null,
                            WebsiteUrl = null,
                            Scale = null,
                            Industry = null,
                            BusinessLicenseUrl = null,
                            Status = "suspended",
                            IsFeatured = 0,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        _context.Companies.Add(company);
                        await _context.SaveChangesAsync();

                        recInfo = new RecruiterInfo
                        {
                            IdUser = user.IdUser,
                            IdCompany = company.IdCompany,
                            Title = null,
                            Department = null,
                            Description = null
                        };
                        _context.RecruiterInfo.Add(recInfo);
                        await _context.SaveChangesAsync();
                    }
                    catch (Exception ex)
                    {
                        return StatusCode(500, $"Save recruiter info failed: {ex.Message}");
                    }
                }
            }
            else
            {
                var candInfo = await _context.CandidateInfo.FindAsync(user.IdUser);
                if (candInfo == null)
                {
                    try
                    {
                        candInfo = new CandidateInfo
                        {
                            IdUser = user.IdUser
                        };
                        _context.CandidateInfo.Add(candInfo);
                        await _context.SaveChangesAsync();
                    }
                    catch (Exception ex)
                    {
                        return StatusCode(500, $"Save candidate info failed: {ex.Message}");
                    }
                }
            }

            var token = GenerateJwtToken(user);

            bool needProfile = false;
            if (requestedRoleName.Equals("Recruiter", StringComparison.OrdinalIgnoreCase))
            {
                var checkRec = await _context.RecruiterInfo.FindAsync(user.IdUser);
                needProfile = checkRec == null || string.IsNullOrWhiteSpace(checkRec.Title);
            }

            var userDto = new UserDto
            {
                IdUser = user.IdUser,
                UserName = user.UserName,
                Email = user.Email,
                IdRole = user.IdRole,
                AvatarUrl = user.AvatarUrl
            };

            return Ok(new SocialLoginResponseDto
            {
                Token = token,
                User = userDto,
                NeedProfile = needProfile
            });
        }

        // Helper: Generate JWT Token
        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["Key"];
            var issuer = jwtSettings["Issuer"];
            var audience = jwtSettings["Audience"];
            var expiryMinutes = int.Parse(jwtSettings["ExpiryInMinutes"]);

            if (string.IsNullOrEmpty(secretKey) || string.IsNullOrEmpty(issuer) || string.IsNullOrEmpty(audience))
                throw new Exception("JWT Settings are not properly configured.");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.IdUser),
                new Claim(ClaimTypes.NameIdentifier, user.IdUser),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
            };

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        // Verify Appwrite JWT by calling /account endpoint
        private async Task<(bool success, string? userId, string? email, string? name, string? avatar, string? error)> VerifyAppwriteJwtAsync(string jwt)
        {
            try
            {
                var endpoint = _configuration["Appwrite:ApiEndpoint"] ?? "https://syd.cloud.appwrite.io/v1";
                var projectId = _configuration["Appwrite:ProjectId"];
                if (string.IsNullOrWhiteSpace(projectId))
                {
                    return (false, null, null, null, null, "Missing Appwrite:ProjectId in configuration");
                }

                using var http = new HttpClient();
                http.DefaultRequestHeaders.Add("X-Appwrite-Project", projectId);
                http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwt);
                var res = await http.GetAsync($"{endpoint.TrimEnd('/')}/account");
                var body = await res.Content.ReadAsStringAsync();
                if (!res.IsSuccessStatusCode)
                {
                    return (false, null, null, null, null, $"Appwrite /account failed: {(int)res.StatusCode} {body}");
                }

                using var doc = JsonDocument.Parse(body);
                var root = doc.RootElement;
                var id = root.TryGetProperty("$id", out var pId) ? pId.GetString() : null;
                var email = root.TryGetProperty("email", out var pEmail) ? pEmail.GetString() : null;
                var name = root.TryGetProperty("name", out var pName) ? pName.GetString() : null;
                string? avatar = null;
                if (root.TryGetProperty("prefs", out var pPrefs) && pPrefs.ValueKind == JsonValueKind.Object)
                {
                    if (pPrefs.TryGetProperty("avatar", out var pAv)) avatar = pAv.GetString();
                }
                if (string.IsNullOrWhiteSpace(id))
                {
                    return (false, null, null, null, null, "Missing $id in Appwrite account response");
                }
                return (true, id, email, name, avatar, null);
            }
            catch (Exception ex)
            {
                return (false, null, null, null, null, ex.Message);
            }
        }
    }
}