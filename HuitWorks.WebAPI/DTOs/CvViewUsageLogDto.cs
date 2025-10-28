// File: DTOs/CvViewUsageLogDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class CvViewUsageLogDto
    {
        public string IdLog { get; set; } = null!;
        public string IdTransaction { get; set; } = null!;
        public string? IdResume { get; set; }
        public DateTime UsedAt { get; set; }
    }

    public class CreateCvViewUsageLogDto
    {
        public string IdTransaction { get; set; } = null!;
        public string? IdResume { get; set; }
        public DateTime? UsedAt { get; set; }
    }

    public class UpdateCvViewUsageLogDto
    {
        public string? IdResume { get; set; }
        public DateTime? UsedAt { get; set; }
    }
}
