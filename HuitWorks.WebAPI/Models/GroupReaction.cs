using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("group_reactions")]
    public class GroupReaction
    {
        [Key]
        [Column("idReaction")]
        [StringLength(64)]
        public string IdReaction { get; set; } = null!;

        [Required]
        [Column("entityType", TypeName = "enum('post','comment')")]
        [StringLength(10)]
        public string EntityType { get; set; } = null!;

        [Required]
        [Column("entityId")]
        [StringLength(64)]
        public string EntityId { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("reaction", TypeName = "enum('like','love','haha','wow','sad','angry')")]
        [StringLength(10)]
        public string Reaction { get; set; } = "like";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}
