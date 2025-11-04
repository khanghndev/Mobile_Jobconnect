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
        /// Đăng ký tài khoản mới
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Validate confirm password
            if (model.Password != model.ConfirmPassword)
                return BadRequest(new { message = "Mật khẩu và xác nhận mật khẩu không khớp" });

            // Xóa OTP và pending registrations hết hạn
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM PendingRegistrations WHERE ExpireAt < UTC_TIMESTAMP()");

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

            // Xóa pending registration và OTP cũ nếu có
            var oldPending = await _context.PendingRegistrations.FirstOrDefaultAsync(p => p.Email == model.Email);
            if (oldPending != null)
            {
                _context.PendingRegistrations.Remove(oldPending);
            }
            var oldOtps = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            if (oldOtps.Any())
            {
                _context.OtpCodes.RemoveRange(oldOtps);
            }

            // Lưu thông tin đăng ký tạm thời
            // Lưu plain password tạm thời để tạo Supabase user sau khi verify OTP
            var pendingReg = new PendingRegistration
            {
                Email = model.Email,
                UserName = model.UserName,
                Password = model.Password, // Lưu plain password tạm thời (sẽ hash khi tạo user)
                PhoneNumber = phone,
                RoleName = model.RoleName,
                SupabaseIdUser = model.SupabaseIdUser,
                CreatedAt = DateTime.UtcNow,
                ExpireAt = DateTime.UtcNow.AddMinutes(10) // Pending registration hết hạn sau 10 phút
            };

            _context.PendingRegistrations.Add(pendingReg);
            await _context.SaveChangesAsync();

            // Tạo OTP 6 số
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

            // Gửi OTP qua SMTP
            try
            {
                string emailHtml = $@"
                <!DOCTYPE html>
                <html>
                <head>
                <meta charset='UTF-8'>
                <title>Confirm your account</title>
                <style>
                    body {{
                    background-color: #f9fafb;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    margin: 0;
                    padding: 0;
                    }}
                    .container {{
                    background-color: #ffffff;
                    max-width: 500px;
                    margin: 40px auto;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                    overflow: hidden;
                    }}
                    .header {{
                    background-color: #2563eb;
                    color: #ffffff;
                    text-align: center;
                    padding: 30px 20px;
                    }}
                    .header img {{
                    width: 60px;
                    height: 60px;
                    margin-bottom: 10px;
                    }}
                    .content {{
                    padding: 30px 25px;
                    color: #374151;
                    text-align: center;
                    }}
                    .button {{
                    display: inline-block;
                    background-color: #2563eb;
                    color: #ffffff !important;
                    text-decoration: none;
                    padding: 12px 24px;
                    border-radius: 8px;
                    font-weight: bold;
                    margin-top: 20px;
                    }}
                    .footer {{
                    font-size: 13px;
                    color: #9ca3af;
                    text-align: center;
                    padding: 20px;
                    }}
                </style>
                </head>
                <body>
                <div class='container'>
                    <div class='header'>
                    <img src='https://syd.cloud.appwrite.io/v1/storage/buckets/68c6ceb60038715a8277/files/6908529c0022711e059b/view?project=68c6ceab002e684cb753&mode=admin' alt='UniJobs Logo' />
                    <h1>Welcome to UniJobs!</h1>
                    </div>
                    <div class='content'>
                    <p>Chào bạn,</p>
                    <p>Cảm ơn bạn đã đăng ký tài khoản tại <strong>UniJobs</strong>!</p>
                    <p>Mã OTP xác thực tài khoản của bạn là:</p>
                    <h2 style='color:#2563eb;font-size:28px;margin:10px 0;'>{otp}</h2>
                    <p>Mã này có hiệu lực trong <b>60 giây</b>.</p>
                    <p>Nếu bạn không yêu cầu mã này, hãy bỏ qua email này.</p>
                    </div>
                    <div class='footer'>
                    © 2025 UniJobs. All rights reserved.
                    </div>
                </div>
                </body>
                </html>";

                await _supabaseAuthService.SendEmailAsync(
                    model.Email,
                    "Xác nhận tài khoản UniJobs",
                    emailHtml
                );
            }
            catch (Exception ex)
            {
                _context.PendingRegistrations.Remove(pendingReg);
                _context.OtpCodes.Remove(otpEntity);
                await _context.SaveChangesAsync();
                return StatusCode(500, new { message = $"Gửi email thất bại: {ex.Message}" });
            }

            return Ok(new { message = "Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra và xác thực để hoàn tất đăng ký." });
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


        /// <summary>
        /// Gửi OTP cho quên mật khẩu
        /// </summary>
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] OtpRequestDto model)
        {
            // Xóa OTP hết hạn
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()");
            
            if (string.IsNullOrWhiteSpace(model.Email))
                return BadRequest(new { message = "Email không được để trống" });

            // Kiểm tra user tồn tại
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng với email này" });

            // Xóa OTP cũ
            var old = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            if (old.Any())
            {
                _context.OtpCodes.RemoveRange(old);
                await _context.SaveChangesAsync();
            }

            // Sinh OTP ngẫu nhiên 6 số
            var otp = new Random().Next(100000, 999999).ToString();

            var otpEntity = new OtpCode
            {
                Email = model.Email,
                CodeInt = otp,
                CreatedAt = DateTime.UtcNow,
                ExpireAt = DateTime.UtcNow.AddMinutes(5) // OTP cho forgot password có hiệu lực 5 phút
            };
            _context.OtpCodes.Add(otpEntity);
            await _context.SaveChangesAsync();

            // Gửi OTP qua email với template đẹp hơn
            try
            {
                string emailHtml = $@"
<!DOCTYPE html>
<html>
<head>
  <meta charset='UTF-8'>
  <title>Đặt lại mật khẩu</title>
  <style>
    body {{
      background-color: #f9fafb;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
    }}
    .container {{
      background-color: #ffffff;
      max-width: 500px;
      margin: 40px auto;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      overflow: hidden;
    }}
    .header {{
      background-color: #dc2626;
      color: #ffffff;
      text-align: center;
      padding: 30px 20px;
    }}
    .header img {{
      width: 60px;
      height: 60px;
      margin-bottom: 10px;
    }}
    .content {{
      padding: 30px 25px;
      color: #374151;
      text-align: center;
    }}
    .otp-code {{
      font-size: 32px;
      font-weight: bold;
      color: #dc2626;
      letter-spacing: 8px;
      margin: 20px 0;
      padding: 15px;
      background-color: #fef2f2;
      border-radius: 8px;
    }}
    .footer {{
      font-size: 13px;
      color: #9ca3af;
      text-align: center;
      padding: 20px;
    }}
    .warning {{
      background-color: #fef2f2;
      border-left: 4px solid #dc2626;
      padding: 12px;
      margin: 20px 0;
      border-radius: 4px;
      font-size: 14px;
    }}
  </style>
</head>
<body>
  <div class='container'>
    <div class='header'>
      <img src='https://syd.cloud.appwrite.io/v1/storage/buckets/68c6ceb60038715a8277/files/6908529c0022711e059b/view?project=68c6ceab002e684cb753&mode=admin' alt='UniJobs Logo' />
      <h1>Đặt lại mật khẩu</h1>
    </div>
    <div class='content'>
      <p>Xin chào,</p>
      <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản UniJobs của mình.</p>
      <p>Mã OTP xác thực của bạn là:</p>
      <div class='otp-code'>{otp}</div>
      <p>Mã này có hiệu lực trong <b>5 phút</b>.</p>
      <div class='warning'>
        <strong>⚠️ Lưu ý:</strong> Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này và kiểm tra bảo mật tài khoản của bạn.
      </div>
    </div>
    <div class='footer'>
      © 2025 UniJobs. All rights reserved.
    </div>
  </div>
</body>
</html>";

                await _supabaseAuthService.SendEmailAsync(
                    model.Email,
                    "Đặt lại mật khẩu UniJobs",
                    emailHtml
                );
            }
            catch (Exception ex)
            {
                _context.OtpCodes.Remove(otpEntity);
                await _context.SaveChangesAsync();
                return StatusCode(500, new { message = $"Gửi email thất bại: {ex.Message}" });
            }

            return Ok(new { message = "Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra và nhập mã để đặt lại mật khẩu." });
        }

        [HttpPost("enter-otp")]
        public async Task<IActionResult> EnterOtp([FromBody] OtpRequestDto model)
        {
            // Xóa OTP hết hạn
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()");
            
            if (string.IsNullOrWhiteSpace(model.Email))
                return BadRequest(new { message = "Email không được để trống" });

            // Xóa OTP cũ
            var old = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            if (old.Any())
            {
                _context.OtpCodes.RemoveRange(old);
                await _context.SaveChangesAsync();
            }

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

            // Gửi OTP qua SMTP
            try
            {
                await _supabaseAuthService.SendEmailAsync(model.Email,
                    "Mã xác thực OTP",
                    $"<h2>Mã xác thực OTP</h2><p>Mã OTP của bạn là: <b style='font-size: 20px; color: #007bff;'>{otp}</b></p><p>Mã này có hiệu lực trong <b>60 giây</b>.</p>");
            }
            catch (Exception ex)
            {
                _context.OtpCodes.Remove(otpEntity);
                await _context.SaveChangesAsync();
                return StatusCode(500, new { message = $"Gửi email thất bại: {ex.Message}" });
            }

            return Ok(new { message = "Mã OTP đã được gửi đến email của bạn" });
        }

        /// <summary>
        /// Verify OTP cho đăng ký - tạo user sau khi verify thành công
        /// </summary>
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRegisterDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.Code))
                return BadRequest(new { message = "Email và mã OTP là bắt buộc" });

            // Xóa OTP hết hạn
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM PendingRegistrations WHERE ExpireAt < UTC_TIMESTAMP()");

            var otp = await _context.OtpCodes.FirstOrDefaultAsync(o => o.Email == model.Email && o.CodeInt == model.Code);
            if (otp == null)
                return BadRequest(new { message = "Mã OTP không hợp lệ" });

            if (otp.ExpireAt < DateTime.UtcNow)
            {
                _context.OtpCodes.Remove(otp);
                await _context.SaveChangesAsync();
                return BadRequest(new { message = "Mã OTP đã hết hạn" });
            }

            // Kiểm tra pending registration
            var pendingReg = await _context.PendingRegistrations.FirstOrDefaultAsync(p => p.Email == model.Email);
            if (pendingReg == null)
                return BadRequest(new { message = "Không tìm thấy thông tin đăng ký. Vui lòng đăng ký lại." });

            if (pendingReg.ExpireAt < DateTime.UtcNow)
            {
                _context.PendingRegistrations.Remove(pendingReg);
                _context.OtpCodes.Remove(otp);
                await _context.SaveChangesAsync();
                return BadRequest(new { message = "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại." });
            }

            // Lấy/khởi tạo role
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == pendingReg.RoleName);
            if (role == null)
            {
                role = new Role
                {
                    IdRole = Guid.NewGuid().ToString(),
                    RoleName = pendingReg.RoleName,
                    Description = $"Auto-created role: {pendingReg.RoleName}"
                };
                _context.Roles.Add(role);
                await _context.SaveChangesAsync();
            }

            string? supabaseUserId = pendingReg.SupabaseIdUser;

            // Tạo user trên Supabase nếu chưa có
            if (string.IsNullOrWhiteSpace(supabaseUserId))
            {
                var supabaseResult = await _supabaseAuthService.CreateUserAsync(
                    email: pendingReg.Email,
                    password: pendingReg.Password, // Note: This is hashed, but Supabase expects plain password
                    name: pendingReg.UserName,
                    phone: pendingReg.PhoneNumber
                );

                if (!supabaseResult.success || string.IsNullOrWhiteSpace(supabaseResult.userId))
                {
                    return BadRequest(new { message = $"Không tạo được tài khoản Supabase: {supabaseResult.error}" });
                }

                supabaseUserId = supabaseResult.userId;
            }

            var idUser = supabaseUserId;

            using var tx = await _context.Database.BeginTransactionAsync();

            try
            {
                // Tạo user
                var user = new User
                {
                    IdUser = idUser,
                    UserName = pendingReg.UserName,
                    Email = pendingReg.Email,
                    PhoneNumber = pendingReg.PhoneNumber,
                    Password = BCrypt.Net.BCrypt.HashPassword(pendingReg.Password), // Hash plain password
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

                // Nếu là Candidate → tạo candidate_info mặc định
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

                // Xóa pending registration và OTP
                _context.PendingRegistrations.Remove(pendingReg);
                _context.OtpCodes.Remove(otp);

                await tx.CommitAsync();

                // Generate JWT token
                var token = GenerateJwtToken(user);

                var result = new
                {
                    Token = token,
                    User = new
                    {
                        IdUser = user.IdUser,
                        UserName = user.UserName,
                        Email = user.Email,
                        IdRole = user.IdRole,
                        AccountStatus = user.AccountStatus
                    },
                    Message = "Đăng ký thành công"
                };

                return Ok(result);
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

        /// <summary>
        /// Verify OTP cho reset password
        /// </summary>
        [HttpPost("verify-otp-reset")]
        public async Task<IActionResult> VerifyOtpReset([FromBody] VerifyOtpDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.Code))
                return BadRequest(new { message = "Email và mã OTP là bắt buộc" });

            await _context.Database.ExecuteSqlRawAsync("DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()");

            var otp = await _context.OtpCodes.FirstOrDefaultAsync(o => o.Email == model.Email && o.CodeInt == model.Code);
            if (otp == null)
                return BadRequest(new { message = "Mã OTP không hợp lệ" });

            if (otp.ExpireAt < DateTime.UtcNow)
            {
                _context.OtpCodes.Remove(otp);
                await _context.SaveChangesAsync();
                return BadRequest(new { message = "Mã OTP đã hết hạn" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            // Verify thành công - OTP vẫn giữ lại để dùng trong reset-password
            // Không xóa OTP ở đây vì cần dùng lại trong bước reset-password
            // Reset-password sẽ xóa tất cả OTP sau khi thành công
            
            return Ok(new { message = "Xác thực OTP thành công, bạn có thể đặt lại mật khẩu" });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto model)
        {
            if (string.IsNullOrWhiteSpace(model.Email) || string.IsNullOrWhiteSpace(model.NewPassword) || string.IsNullOrWhiteSpace(model.ConfirmPassword))
                return BadRequest(new { message = "Thiếu thông tin bắt buộc" });

            // Validate confirm password
            if (model.NewPassword != model.ConfirmPassword)
                return BadRequest(new { message = "Mật khẩu mới và xác nhận mật khẩu không khớp" });

            // Validate password format
            if (!System.Text.RegularExpressions.Regex.IsMatch(model.NewPassword, @"^(?=.*[#@$%&]).{8,}$"))
                return BadRequest(new { message = "Mật khẩu phải có ít nhất 8 ký tự và chứa ít nhất một ký tự đặc biệt (#@$%&)" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            // Kiểm tra đã verify OTP (có OTP hợp lệ cho email này)
            var otp = await _context.OtpCodes
                .Where(o => o.Email == model.Email && o.ExpireAt >= DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();

            if (otp == null)
                return BadRequest(new { message = "Vui lòng xác thực OTP trước khi đặt lại mật khẩu" });

            // Cập nhật password trong database
            user.Password = BCrypt.Net.BCrypt.HashPassword(model.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            // Cập nhật password trên Supabase nếu user có Supabase account (IdUser là Supabase userId)
            // Kiểm tra xem IdUser có phải là UUID format của Supabase không
            bool isSupabaseUser = Guid.TryParse(user.IdUser, out _);
            if (isSupabaseUser)
            {
                try
                {
                    var updateResult = await _supabaseAuthService.UpdatePasswordAsync(user.IdUser, model.NewPassword);
                    if (!updateResult)
                    {
                        // Log warning nhưng không fail nếu không update được Supabase
                        Console.WriteLine($"[ResetPassword] Warning: Failed to update Supabase password for user {user.IdUser}");
                    }
                }
                catch (Exception ex)
                {
                    // Log nhưng không fail transaction
                    Console.WriteLine($"[ResetPassword] Warning: Exception updating Supabase password: {ex.Message}");
                }
            }

            // Xóa tất cả OTP của email này sau khi reset thành công
            var allOtps = await _context.OtpCodes.Where(o => o.Email == model.Email).ToListAsync();
            _context.OtpCodes.RemoveRange(allOtps);
            
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đặt lại mật khẩu thành công. Vui lòng đăng nhập với mật khẩu mới." });
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