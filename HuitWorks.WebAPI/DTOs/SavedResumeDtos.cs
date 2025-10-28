using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    // Output DTO cho GET
    public class SavedResumeDto
    {
        public string IdSave { get; set; } = null!;
        public string IdRecruiter { get; set; } = null!;
        public string IdCandidate { get; set; } = null!;
        public DateTime SavedAt { get; set; }
    }

    // Input DTO cho POST (tạo mới)
    public class CreateSavedResumeDto
    {
        [Required(ErrorMessage = "ID nhà tuyển dụng là bắt buộc.")]
        [StringLength(50, ErrorMessage = "ID nhà tuyển dụng không được vượt quá 50 ký tự.")]
        public string IdRecruiter { get; set; } = null!;

        [Required(ErrorMessage = "ID ứng viên là bắt buộc.")]
        [StringLength(50, ErrorMessage = "ID ứng viên không được vượt quá 50 ký tự.")]
        public string IdCandidate { get; set; } = null!;

        // Ngày lưu nếu không gửi, server tự gán DateTime.UtcNow
        public DateTime? SavedAt { get; set; }
    }
}
