using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialConnection")]
    public class SocialConnection
    {
        [Key]
        [Column("idUser1")]
        [StringLength(64)]
        public string IdUser1 { get; set; } = null!;

        [Key]
        [Column("idUser2")]
        [StringLength(64)]
        public string IdUser2 { get; set; } = null!;

        [Column("status", TypeName = "enum('pending','accepted','blocked')")]
        [StringLength(10)]
        public string Status { get; set; } = "pending";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdUser1))]
        public User? User1 { get; set; }

        [ForeignKey(nameof(IdUser2))]
        public User? User2 { get; set; }
    }
}


