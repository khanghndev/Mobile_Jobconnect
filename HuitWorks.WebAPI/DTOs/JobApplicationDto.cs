using HuitWorks.WebAPI.Models;
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class JobApplicationDto
    {
        public string IdJobPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? CvFileUrl { get; set; }
        public string? CoverLetter { get; set; }
        public string ApplicationStatus { get; set; } = null!;
        public DateTime SubmittedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public JobPosting? JobPosting { get; set; } = null;
    }

    public class CreateJobApplicationDto
    {
        // Không cho client cung cấp IdJobApp, SubmittedAt, UpdatedAt
        [Required(ErrorMessage = "IdJobPost là bắt buộc.")]
        public string IdJobPost { get; set; } = null!;

        [Required(ErrorMessage = "IdUser là bắt buộc.")]
        public string IdUser { get; set; } = null!;

        public string? CvFileUrl { get; set; }

        public string? CoverLetter { get; set; }

        [Required(ErrorMessage = "ApplicationStatus là bắt buộc.")]
        public string ApplicationStatus { get; set; } = null!;
    }

    public class UpdateJobApplicationDto
    {
        public string? CvFileUrl { get; set; }

        public string? CoverLetter { get; set; }

        [Required(ErrorMessage = "ApplicationStatus là bắt buộc.")]
        public string ApplicationStatus { get; set; } = null!;
    }
}
