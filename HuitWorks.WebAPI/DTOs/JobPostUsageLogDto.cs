// File: DTOs/JobPostUsageLogDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class JobPostUsageLogDto
    {
        public string IdLog { get; set; } = null!;
        public string IdTransaction { get; set; } = null!;
        public string? IdJobPost { get; set; }
        public DateTime UsedAt { get; set; }
    }

    public class CreateJobPostUsageLogDto
    {
        public string IdTransaction { get; set; } = null!;
        public string? IdJobPost { get; set; }
        public DateTime? UsedAt { get; set; }
    }

    public class UpdateJobPostUsageLogDto
    {
        public string? IdJobPost { get; set; }
        public DateTime? UsedAt { get; set; }
    }
}
