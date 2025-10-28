using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("users")]
    public class User
    {
        [Key]
        [Column("idUser")]
        public string? IdUser { get; set; }

        //[Required]
        [Column("userName")]
        public string? UserName { get; set; }

        //[Required]
        [Column("email")]
        public string? Email { get; set; }

        [Column("phoneNumber")]
        public string? PhoneNumber { get; set; }

        [Column("password")]
        public string? Password { get; set; }

        //[Required]
        [Column("idRole")]
        public string? IdRole { get; set; }

        //[Required]
        [Column("accountStatus")]
        public string? AccountStatus { get; set; }

        [Column("avatarUrl")]
        public string? AvatarUrl { get; set; }

        [Column("socialLogin")]
        public string? SocialLogin { get; set; }

        [Column("createdAt")]
        public DateTime? CreatedAt { get; set; }

        [Column("updatedAt")]
        public DateTime? UpdatedAt { get; set; }

        [Column("gender")]
        public string? Gender { get; set; }

        [Column("address")]
        public string? Address { get; set; }

        [Column("dateOfBirth")]
        public DateTime? DateOfBirth { get; set; }

        // Navigation property
        [ForeignKey(nameof(IdRole))]
        public Role? Role { get; set; }
    }
}
