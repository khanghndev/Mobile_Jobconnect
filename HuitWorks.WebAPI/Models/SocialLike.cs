using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialLike")]
    public class SocialLike
    {
        [Key]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Key]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdPost))]
        public SocialPost? Post { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}


