using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class ResumeDto
    {
        public string IdResume { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? FileUrl { get; set; } = null!;
        public string FileName { get; set; } = null!;
        public string? FileId { get; set; }
        public int FileSizeKB { get; set; }
        public int IsDefault { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateResumeDto
    {
        [Required]
        public string IdUser { get; set; } = null!;

        [Required]
        public string FileUrl { get; set; } = null!;

        [Required]
        public string FileName { get; set; } = null!;

        public string? FileId { get; set; }

        [Required]
        public int FileSizeKB { get; set; }

        [Required]
        public int IsDefault { get; set; }   // 1 hoặc 0

        // (Không truyền CreatedAt/UpdatedAt từ client, WebAPI sẽ tự động gán)
    }

    public class UpdateResumeDto
    {
        public string? FileUrl { get; set; }
        public string? FileName { get; set; }
        public int? FileSizeKB { get; set; }
        public int? IsDefault { get; set; }
    }

    public class SetDefaultResumeDto
    {
        [Required]
        public string UserId { get; set; } = null!;

        public string? FileId { get; set; }
        
        public string? ResumeId { get; set; }
    }
}
