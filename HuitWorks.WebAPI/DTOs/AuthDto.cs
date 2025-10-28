using System.ComponentModel.DataAnnotations;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.DTOs
{
    // DTO dùng khi đăng ký tài khoản
    public class RegisterDto
    {
        [Required(ErrorMessage = "UserName is required.")]
        public string UserName { get; set; } = null!;

        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string Email { get; set; } = null!;

        [Required(ErrorMessage = "Password is required.")]
        [RegularExpression(@"^(?=.*[#@$%&]).{8,}$", ErrorMessage = "Password must be at least 8 characters and contain at least one special character (#@$%&).")]
        public string Password { get; set; } = null!;

        [Phone(ErrorMessage = "Invalid phone number format.")]
        public string? PhoneNumber { get; set; }

        [Required(ErrorMessage = "RoleName is required.")]
        public string RoleName { get; set; } = "Candidate"; // mặc định Candidate
        public string? AppwriteUserId { get; set; }
    }
    // DTO dùng khi đăng nhập
    public class LoginDto
    {
        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string Email { get; set; } = null!;

        [Required(ErrorMessage = "Password is required.")]
        public string Password { get; set; } = null!;
    }

    // DTO trả về khi xác thực thành công
    public class AuthResponse
    {
        public string Token { get; set; } = null!;
        public User User { get; set; } = null!;
    }
}
