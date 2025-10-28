using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("ReportType")]
    public class ReportType
    {
        [Key]
        [Column("ReportTypeId")]
        public int ReportTypeId { get; set; }

        [Required]
        [Column("Name")]
        [StringLength(100)]
        public string Name { get; set; } = null!;

        [Column("Description")]
        public string? Description { get; set; }

        [Column("CreatedDate")]
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
