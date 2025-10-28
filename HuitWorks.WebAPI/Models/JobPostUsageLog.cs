// File: Models/JobPostUsageLog.cs
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("JobPostUsageLog")]
    public class JobPostUsageLog
    {
        [Key]
        [Column("idLog")]
        [StringLength(64)]
        public string IdLog { get; set; } = null!;

        [Required]
        [Column("idTransaction")]
        [StringLength(50)]
        public string IdTransaction { get; set; } = null!;

        [Column("idJobPost")]
        [StringLength(64)]
        public string? IdJobPost { get; set; }

        [Required]
        [Column("usedAt")]
        public DateTime UsedAt { get; set; }

        // Navigation
        [ForeignKey(nameof(IdTransaction))]
        public JobTransaction? JobTransaction { get; set; }

        [ForeignKey(nameof(IdJobPost))]
        public JobPosting? JobPosting { get; set; }
    }
}