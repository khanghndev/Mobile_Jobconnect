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
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using HuitWorks.WebAPI.Services;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly ISupabaseAuthService _supabaseAuthService;

        public AuthController(JobConnectDbContext context, IConfiguration configuration, ISupabaseAuthService supabaseAuthService)
        {
            _context = context;
            _configuration = configuration;
            _supabaseAuthService = supabaseAuthService;
        }

        /// <summary>
        /// Đăng ký tài khoản mới với Supabase
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (await _context.Users.AnyAsync(u => u.Email == model.Email))
                return BadRequest(new { message = "Email đã tồn tại" });

            // Chuẩn hóa phone (đề phòng client chưa chuẩn hóa)
            string phone = NormalizeToE164(model.PhoneNumber);

            // Kiểm tra phone number đã tồn tại (chỉ khi phone không rỗng)
            if (!string.IsNullOrWhiteSpace(phone))
            {
                if (await _context.Users.AnyAsync(u => u.PhoneNumber == phone))
                    return BadRequest(new { message = "Số điện thoại đã tồn tại" });
            }

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

            string? supabaseUserId = null;

            // Phase 1: Tạo user trên Supabase
            if (string.IsNullOrWhiteSpace(model.AppwriteUserId))
            {
                var supabaseResult = await _supabaseAuthService.CreateUserAsync(
                    email: model.Email,
                    password: model.Password,
                    name: model.UserName,
                    phone: phone
                );

                if (!supabaseResult.success || string.IsNullOrWhiteSpace(supabaseResult.userId))
                {
                    return BadRequest(new { message = $"Không tạo được tài khoản Supabase: {supabaseResult.error}" });
                }

                supabaseUserId = supabaseResult.userId;
            }
            else
            {
                supabaseUserId = model.AppwriteUserId.Trim();
            }

            // Chọn IdUser: sử dụng SupabaseUserId để mapping 1-1 với Supabase
            var idUser = supabaseUserId;

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

                // Gửi email verification từ Supabase (không chặn flow nếu fail)
                try
                {
                    var verifyRedirect = Request.Scheme + "://" + Request.Host + "/Auth/Login";
                    await _supabaseAuthService.SendEmailVerificationAsync(supabaseUserId, verifyRedirect);
                }
                catch { /* ignore email verification errors */ }

                var result = new
                {
                    IdUser = user.IdUser,
                    Message = "Đăng ký thành công",
                    CandidateInfoCreated = role.RoleName.Equals("Candidate", StringComparison.OrdinalIgnoreCase)
                };

                return CreatedAtAction(nameof(GetById), new { id = user.IdUser }, result);
            }
            catch (DbUpdateException dbEx)
            {
                await tx.RollbackAsync();
                // Nếu tạo DB fail, xóa user trên Supabase
                if (!string.IsNullOrWhiteSpace(supabaseUserId))
                {
                    await _supabaseAuthService.DeleteUserAsync(supabaseUserId);
                }

                // Kiểm tra lỗi duplicate key
                if (dbEx.InnerException?.Message?.Contains("Duplicate entry") == true)
                {
                    if (dbEx.InnerException.Message.Contains("phoneNumber"))
                    {
                        return BadRequest(new { message = "Số điện thoại đã tồn tại trong hệ thống" });
                    }
                    if (dbEx.InnerException.Message.Contains("email"))
                    {
                        return BadRequest(new { message = "Email đã tồn tại trong hệ thống" });
                    }
                    return BadRequest(new { message = "Thông tin đăng ký đã tồn tại trong hệ thống" });
                }

                return StatusCode(500, new { message = "Đăng ký thất bại", detail = dbEx.Message });
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                // Nếu tạo DB fail, xóa user trên Supabase
                if (!string.IsNullOrWhiteSpace(supabaseUserId))
                {
                    await _supabaseAuthService.DeleteUserAsync(supabaseUserId);
                }
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

            // Verify Supabase JWT
            var verify = await _supabaseAuthService.VerifySupabaseJwtAsync(model.IdToken);
            if (!verify.success)
            {
                return BadRequest($"Invalid Supabase token: {verify.error}");
            }

            var email = string.IsNullOrWhiteSpace(model.Email) ? (string.IsNullOrWhiteSpace(verify.email) ? $"{verify.userId}@supabase.local" : verify.email!.Trim()) : model.Email.Trim();
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
                        Email = string.IsNullOrWhiteSpace(email) ? $"{verify.userId}@supabase.local" : email,
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


        [HttpPost("enter-otp")]
        public async Task<IActionResult> EnterOtp([FromBody] OtpCode model)
        {
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCodes WHERE ExpireAt < UTC_TIMESTAMP()");
            if (string.IsNullOrWhiteSpace(model.Email))
                return BadRequest(new { message = "Email không được để trống" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng với email này" });

            // Xóa OTP cũ
            var old = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            _context.OtpCodes.RemoveRange(old);

            // Sinh OTP ngẫu nhiên 6 số
            var otp = new Random().Next(100000, 999999).ToString();

            var otpEntity = new OtpCode
            {
                Email = model.Email,
                CodeInt = otp,
                CreatedAt = DateTime.UtcNow,
                ExpireAt = DateTime.UtcNow.AddSeconds(60)
            };
            _context.OtpCodes.Add(otpEntity);
            await _context.SaveChangesAsync();

            // Gửi OTP qua Supabase (hoặc SMTP)
            try
            {
                await _supabaseAuthService.SendEmailAsync(model.Email,
                    "Mã xác thực OTP",
                    $"<p>Mã OTP của bạn là: <b>{otp}</b><br/>Hiệu lực trong 60 giây.</p>");
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Gửi email thất bại: {ex.Message}" });
            }

            return Ok(new { message = "Mã OTP đã được gửi đến email của bạn" });
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.Code))
                return BadRequest(new { message = "Email và mã OTP là bắt buộc" });

            var otp = await _context.OtpCodes.FirstOrDefaultAsync(o => o.Email == model.Email && o.CodeInt == model.Code);
            if (otp == null)
                return BadRequest(new { message = "Mã OTP không hợp lệ" });

            if (otp.ExpireAt < DateTime.UtcNow)
            {
                _context.OtpCodes.Remove(otp);
                await _context.SaveChangesAsync();
                return BadRequest(new { message = "Mã OTP đã hết hạn" });
            }

            // Hợp lệ → cho phép reset password
            return Ok(new { message = "Xác thực OTP thành công, bạn có thể đặt lại mật khẩu" });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.NewPassword))
                return BadRequest(new { message = "Thiếu thông tin bắt buộc" });

            var otp = await _context.OtpCodes
                .Where(o => o.Email == model.Email && o.CodeInt == model.OtpCode)
                .FirstOrDefaultAsync();

            if (otp == null)
                return BadRequest(new { message = "Mã OTP không hợp lệ hoặc chưa xác thực" });

            if (otp.ExpireAt < DateTime.UtcNow)
            {
                _context.OtpCodes.Remove(otp);
                await _context.SaveChangesAsync();
                return BadRequest(new { message = "Mã OTP đã hết hạn" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            user.Password = BCrypt.Net.BCrypt.HashPassword(model.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            _context.OtpCodes.Remove(otp); // Xóa OTP sau khi reset thành công
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đặt lại mật khẩu thành công" });
        }

        [HttpPost("resend-otp")]
        public async Task<IActionResult> ResendOtp([FromBody] OtpRequestDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email))
                return BadRequest(new { message = "Email không được để trống" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng với email này" });

            // Xóa OTP cũ nếu có
            var oldOtps = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            if (oldOtps.Any())
            {
                _context.OtpCodes.RemoveRange(oldOtps);
                await _context.SaveChangesAsync();
            }

            // Sinh OTP mới
            var otp = new Random().Next(100000, 999999).ToString();

            var otpEntity = new OtpCode
            {
                Email = model.Email,
                CodeInt = otp,
                CreatedAt = DateTime.UtcNow,
                ExpireAt = DateTime.UtcNow.AddSeconds(60)
            };
            _context.OtpCodes.Add(otpEntity);
            await _context.SaveChangesAsync();

            try
            {
                await _supabaseAuthService.SendEmailAsync(model.Email,
                    "Mã xác thực OTP (Gửi lại)",
                    $"<p>Mã OTP mới của bạn là: <b>{otp}</b><br/>Hiệu lực trong 60 giây.</p>");
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Gửi lại email thất bại: {ex.Message}" });
            }

            return Ok(new { message = "Đã gửi lại mã OTP mới đến email của bạn" });
        }


    }
    
}