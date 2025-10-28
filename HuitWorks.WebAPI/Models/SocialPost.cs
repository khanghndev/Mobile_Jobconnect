using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialPost")]
    public class SocialPost
    {
        [Key]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("idGroup")]
        [StringLength(64)]
        public string? IdGroup { get; set; }

        [Required]
        [Column("content", TypeName = "TEXT")]
        public string Content { get; set; } = null!;

        [Column("imageUrl")]
        public string? ImageUrl { get; set; }

        [Column("videoUrl")]
        public string? VideoUrl { get; set; }

        [Column("visibility", TypeName = "enum('public','friends','private')")]
        [StringLength(10)]
        public string Visibility { get; set; } = "public";

        [Column("postType", TypeName = "enum('post','qa','job','microjob')")]
        [StringLength(16)]
        public string PostType { get; set; } = "post";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(IdGroup))]
        public SocialGroup? Group { get; set; }
    }
}





