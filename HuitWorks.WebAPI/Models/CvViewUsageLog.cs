// File: Models/CvViewUsageLog.cs
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("CvViewUsageLog")]
    public class CvViewUsageLog
    {
        [Key]
        [Column("idLog")]
        [StringLength(64)]
        public string IdLog { get; set; } = null!;

        [Required]
        [Column("idTransaction")]
        [StringLength(50)]
        public string IdTransaction { get; set; } = null!;

        [Column("idResume")]
        [StringLength(64)]
        public string? IdResume { get; set; }

        [Required]
        [Column("usedAt")]
        public DateTime UsedAt { get; set; }

        // Navigation
        [ForeignKey(nameof(IdTransaction))]
        public JobTransaction? JobTransaction { get; set; }

        [ForeignKey(nameof(IdResume))]
        public Resume? Resume { get; set; }
    }
}
