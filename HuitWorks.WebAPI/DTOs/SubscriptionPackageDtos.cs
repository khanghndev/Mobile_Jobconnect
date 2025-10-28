// File: DTOs/SubscriptionPackageDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class SubscriptionPackageDto
    {
        public string IdPackage { get; set; } = null!;
        public string PackageName { get; set; } = null!;
        public decimal Price { get; set; }
        public int DurationDays { get; set; }
        public string? Description { get; set; }
        public int JobPostLimit { get; set; }
        public int CvViewLimit { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }

    public class CreateSubscriptionPackageDto
    {
        public string PackageName { get; set; } = null!;
        public decimal Price { get; set; }
        public int DurationDays { get; set; }
        public string? Description { get; set; }
        public int JobPostLimit { get; set; }
        public int CvViewLimit { get; set; }
    }

    public class UpdateSubscriptionPackageDto
    {
        public string? PackageName { get; set; }
        public decimal? Price { get; set; }
        public int? DurationDays { get; set; }
        public string? Description { get; set; }
        public int? JobPostLimit { get; set; }
        public int? CvViewLimit { get; set; }
        public bool? IsActive { get; set; }
    }
}
