using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("cv_export")]
    public class CvExport
    {
        [Key]
        [Column("idExport")]
        [StringLength(64)]
        public string IdExport { get; set; } = string.Empty;

        [Required]
        [Column("idDocument")]
        [StringLength(64)]
        public string IdDocument { get; set; } = string.Empty;

        [Column("format")]
        public CvExportFormat Format { get; set; } = CvExportFormat.Pdf;

        [Required]
        [Column("fileUrl")]
        [StringLength(1000)]
        public string FileUrl { get; set; } = string.Empty;

        [Column("fileSizeKB")]
        public int? FileSizeKB { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation properties
        [ForeignKey("IdDocument")]
        public virtual CvDocument Document { get; set; } = null!;
    }

    public enum CvExportFormat
    {
        Pdf,
        Html
    }
}
