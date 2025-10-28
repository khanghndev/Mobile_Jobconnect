using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("cv_document")]
    public class CvDocument
    {
        [Key]
        [Column("idDocument")]
        [StringLength(64)]
        public string IdDocument { get; set; } = string.Empty;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = string.Empty;

        [Required]
        [Column("idTemplate")]
        [StringLength(64)]
        public string IdTemplate { get; set; } = string.Empty;

        [Column("title")]
        [StringLength(128)]
        public string? Title { get; set; }

        [Column("locale")]
        [StringLength(16)]
        public string Locale { get; set; } = "vi-VN";

        [Column("colorScheme")]
        [StringLength(64)]
        public string? ColorScheme { get; set; }

        [Required]
        [Column("contentJson")]
        public string ContentJson { get; set; } = string.Empty;

        [Column("status")]
        public CvDocumentStatus Status { get; set; } = CvDocumentStatus.Draft;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // Navigation properties
        [ForeignKey("IdUser")]
        public virtual User User { get; set; } = null!;

        [ForeignKey("IdTemplate")]
        public virtual CvTemplate Template { get; set; } = null!;

        public virtual ICollection<CvExport> CvExports { get; set; } = new List<CvExport>();
        public virtual ICollection<CvShareLink> CvShareLinks { get; set; } = new List<CvShareLink>();
    }

    public enum CvDocumentStatus
    {
        Draft,
        Published
    }
}
