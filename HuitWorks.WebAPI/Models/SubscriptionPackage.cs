// File: Models/SubscriptionPackage.cs
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("SubscriptionPackage")]
    public class SubscriptionPackage
    {
        [Key]
        [Column("idPackage")]
        [StringLength(50)]
        public string IdPackage { get; set; } = null!;

        [Required]
        [Column("packageName")]
        [StringLength(100)]
        public string PackageName { get; set; } = null!;

        [Required]
        [Column("price")]
        public decimal Price { get; set; }

        [Required]
        [Column("durationDays")]
        public int DurationDays { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Required]
        [Column("jobPostLimit")]
        public int JobPostLimit { get; set; }

        [Required]
        [Column("cvViewLimit")]
        public int CvViewLimit { get; set; }

        [Required]
        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        [Required]
        [Column("isActive")]
        public bool IsActive { get; set; }

        // Navigation property: danh sách giao dịch đã mua gói này (nếu cần)
        public ICollection<JobTransaction>? JobTransactions { get; set; }
    }
}
