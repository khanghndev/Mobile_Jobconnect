using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
  public class OtpRequestDto
    {
        public string Email { get; set; } = null!;
    }

    public class VerifyOtpDto
    {
        public string Email { get; set; } = null!;
        public string Code { get; set; } = null!;
    }

    public class ResetPasswordDto
    {
        public string Email { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
        public string ConfirmPassword { get; set; } = null!;
    }

    public class VerifyOtpRegisterDto
    {
        public string Email { get; set; } = null!;
        public string Code { get; set; } = null!;
    }
}
