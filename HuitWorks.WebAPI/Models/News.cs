using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("News")]
    public class News
    {
        [Key]
        [Column("id")]
        public int IdNews { get; set; }

        [Required]
        [Column("title")]
        [StringLength(255)]
        public required string Title { get; set; }

        [Required]
        [Column("content")]
        public required string Content { get; set; }

        [Column("summary")]
        [StringLength(500)]
        public string? Summary { get; set; }

        [Column("imageUrl")]
        [StringLength(255)]
        public string? ImageUrl { get; set; }

        [Required]
        [Column("publishDate")]
        public DateTime PublishDate { get; set; }

        [Column("author")]
        [StringLength(100)]
        public string? Author { get; set; }

        [Required]
        [Column("isPublished")]
        public bool IsPublished { get; set; }

        [Required]
        [Column("categoryName")]
        [StringLength(100)]
        public required string CategoryName { get; set; }

        [Required]
        [Column("targetAudience")]
        [StringLength(20)]
        public required string TargetAudience { get; set; } // All, Candidate, Employer
    }
}
