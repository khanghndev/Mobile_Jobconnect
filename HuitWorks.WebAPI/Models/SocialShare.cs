using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("social_shares")]
    public class SocialShare
    {
        [Key]
        [Column("idShare")]
        [StringLength(64)]
        public string IdShare { get; set; } = null!;

        [Required]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("shareType", TypeName = "enum('public', 'friends', 'only_me', 'group')")]
        [StringLength(20)]
        public string ShareType { get; set; } = "public";

        [Column("sharedWithGroup")]
        [StringLength(64)]
        public string? SharedWithGroup { get; set; }

        [Column("sharedAt")]
        public DateTime SharedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(IdPost))]
        public SocialPost? Post { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(SharedWithGroup))]
        public SocialGroup? Group { get; set; }
    }
}

