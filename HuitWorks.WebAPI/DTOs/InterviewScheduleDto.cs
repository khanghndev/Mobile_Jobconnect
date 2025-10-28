using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class InterviewScheduleDto
    {
        public string IdSchedule { get; set; } = null!;
        public string IdJobPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public DateTime InterviewDate { get; set; }
        public string? InterviewMode { get; set; }
        public string? Location { get; set; }
        public string? Interviewer { get; set; }
        public string? Note { get; set; }
    }

    public class CreateInterviewScheduleDto
    {
        [Required]
        [StringLength(64)]
        public string IdJobPost { get; set; } = null!;

        [Required]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        public DateTime InterviewDate { get; set; }

        [StringLength(50)]
        public string? InterviewMode { get; set; }

        [StringLength(255)]
        public string? Location { get; set; }

        [StringLength(100)]
        public string? Interviewer { get; set; }

        [StringLength(500)]
        public string? Note { get; set; }
    }

    public class UpdateInterviewScheduleDto
    {
        [Required]
        public DateTime InterviewDate { get; set; }

        [StringLength(50)]
        public string? InterviewMode { get; set; }

        [StringLength(255)]
        public string? Location { get; set; }

        [StringLength(100)]
        public string? Interviewer { get; set; }

        [StringLength(500)]
        public string? Note { get; set; }
    }
}
