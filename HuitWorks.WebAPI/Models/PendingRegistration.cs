using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("PendingRegistrations")]
    public class PendingRegistration
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("email")]
        [Required, StringLength(255)]
        public string Email { get; set; } = null!;

        [Column("userName")]
        [Required, StringLength(255)]
        public string UserName { get; set; } = null!;

        [Column("password")]
        [Required]
        public string Password { get; set; } = null!;

        [Column("phoneNumber")]
        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        [Column("roleName")]
        [Required, StringLength(50)]
        public string RoleName { get; set; } = null!;

        [Column("supabaseIdUser")]
        [StringLength(255)]
        public string? SupabaseIdUser { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        [Column("expireAt")]
        public DateTime ExpireAt { get; set; }
    }
}

