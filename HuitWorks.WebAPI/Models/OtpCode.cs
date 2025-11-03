using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("OtpCode")]
    public class OtpCode
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("email")]
        [Required, StringLength(255)]
        public string Email { get; set; } = null!;

        [Column("codeInt")]
        [Required, StringLength(10)]
        public string CodeInt { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        [Column("expireAt")]
        public DateTime ExpireAt { get; set; }
    }
}
