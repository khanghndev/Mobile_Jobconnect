using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("social_reactions")]
    public class SocialReaction
    {
        [Key]
        [Column("idReaction")]
        [StringLength(64)]
        public string IdReaction { get; set; } = null!;

        [Required]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("reaction_type", TypeName = "enum('like', 'love', 'haha', 'wow', 'sad', 'angry')")]
        [StringLength(20)]
        public string ReactionType { get; set; } = "like";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(IdPost))]
        public SocialPost? Post { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}

