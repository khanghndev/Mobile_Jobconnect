using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class ReportDto
    {
        public string ReportId { get; set; } = null!;
        public string UserId { get; set; } = null!;
        public int ReportTypeId { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        public ReportTypeDto? ReportType { get; set; }
    }

    public class CreateReportDto
    {
        [Required(ErrorMessage = "UserId is required.")]
        [StringLength(64, ErrorMessage = "UserId cannot exceed 64 characters.")]
        public string UserId { get; set; } = null!;

        [Required(ErrorMessage = "ReportTypeId is required.")]
        public int ReportTypeId { get; set; }

        [StringLength(255, ErrorMessage = "Title cannot exceed 255 characters.")]
        public string? Title { get; set; }

        public string? Content { get; set; }
    }

    public class UpdateReportDto
    {
        [Required(ErrorMessage = "ReportTypeId is required.")]
        public int ReportTypeId { get; set; }

        [StringLength(255, ErrorMessage = "Title cannot exceed 255 characters.")]
        public string? Title { get; set; }

        public string? Content { get; set; }
    }
}
