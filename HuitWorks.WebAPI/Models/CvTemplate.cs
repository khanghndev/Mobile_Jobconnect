using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("cv_template")]
    public class CvTemplate
    {
        [Key]
        [Column("idTemplate")]
        [StringLength(64)]
        public string IdTemplate { get; set; } = string.Empty;

        [Required]
        [Column("slug")]
        [StringLength(64)]
        public string Slug { get; set; } = string.Empty;

        [Required]
        [Column("name")]
        [StringLength(128)]
        public string Name { get; set; } = string.Empty;

        [Column("engine")]
        [StringLength(20)]
        public string Engine { get; set; } = "Razor";

        [Column("previewUrl")]
        [StringLength(1000)]
        public string? PreviewUrl { get; set; }

        [Column("isActive")]
        public bool IsActive { get; set; } = true;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // Navigation properties
        public virtual ICollection<CvDocument> CvDocuments { get; set; } = new List<CvDocument>();
    }

    public enum CvTemplateEngine
    {
        Razor,
        Html,
        QuestPdf
    }
}
