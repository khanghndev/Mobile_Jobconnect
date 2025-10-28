using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("Report")]
    public class Report
    {
        [Key]
        [Column("ReportId")]
        [StringLength(64)]
        public string ReportId { get; set; } = null!;

        [Required]
        [Column("UserId")]
        [StringLength(64)]
        public string UserId { get; set; } = null!;

        [Required]
        [Column("ReportTypeId")]
        public int ReportTypeId { get; set; } 

        [Column("Title")]
        [StringLength(255)]
        public string? Title { get; set; }

        [Column("Content")]
        public string? Content { get; set; }

        [Column("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("UpdatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }

        [ForeignKey(nameof(ReportTypeId))]
        public ReportType? ReportType { get; set; }
    }
}
