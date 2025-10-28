using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class CandidateProjectsDto
    {
        public string IdProject { get; set; } = string.Empty;
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên dự án là bắt buộc")]
        [StringLength(255, ErrorMessage = "Tên dự án không được vượt quá 255 ký tự")]
        public string ProjectName { get; set; } = string.Empty;
        
        [StringLength(1000, ErrorMessage = "URL dự án không được vượt quá 1000 ký tự")]
        public string? ProjectUrl { get; set; }
        
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateCandidateProjectsDto
    {
        [Required(ErrorMessage = "ID người dùng là bắt buộc")]
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên dự án là bắt buộc")]
        [StringLength(255, ErrorMessage = "Tên dự án không được vượt quá 255 ký tự")]
        public string ProjectName { get; set; } = string.Empty;
        
        [StringLength(1000, ErrorMessage = "URL dự án không được vượt quá 1000 ký tự")]
        public string? ProjectUrl { get; set; }
        
        public string? Description { get; set; }
    }

    public class UpdateCandidateProjectsDto
    {
        [Required(ErrorMessage = "ID dự án là bắt buộc")]
        public string IdProject { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên dự án là bắt buộc")]
        [StringLength(255, ErrorMessage = "Tên dự án không được vượt quá 255 ký tự")]
        public string ProjectName { get; set; } = string.Empty;
        
        [StringLength(1000, ErrorMessage = "URL dự án không được vượt quá 1000 ký tự")]
        public string? ProjectUrl { get; set; }
        
        public string? Description { get; set; }
    }
}
