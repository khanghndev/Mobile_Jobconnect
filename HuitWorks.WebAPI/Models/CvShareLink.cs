using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("cv_share_link")]
    public class CvShareLink
    {
        [Key]
        [Column("idShare")]
        [StringLength(64)]
        public string IdShare { get; set; } = string.Empty;

        [Required]
        [Column("idDocument")]
        [StringLength(64)]
        public string IdDocument { get; set; } = string.Empty;

        [Required]
        [Column("token")]
        [StringLength(128)]
        public string Token { get; set; } = string.Empty;

        [Column("accessLevel")]
        public CvShareAccessLevel AccessLevel { get; set; } = CvShareAccessLevel.View;

        [Column("expireAt")]
        public DateTime? ExpireAt { get; set; }

        [Column("isActive")]
        public bool IsActive { get; set; } = true;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation properties
        [ForeignKey("IdDocument")]
        public virtual CvDocument Document { get; set; } = null!;
    }

    public enum CvShareAccessLevel
    {
        View,
        Download
    }
}
