using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("group_members")]
    public class GroupMember
    {
        [Key]
        [Column("idGroup")]
        [StringLength(64)]
        public string IdGroup { get; set; } = null!;

        [Key]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("roleInGroup", TypeName = "enum('owner','admin','moderator','member')")]
        [StringLength(15)]
        public string RoleInGroup { get; set; } = "member";

        [Column("joinedAt")]
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

        [Required]
        [Column("status", TypeName = "enum('active','pending','banned')")]
        [StringLength(10)]
        public string Status { get; set; } = "active";

        // Navigation properties
        [ForeignKey(nameof(IdGroup))]
        public SocialGroup? SocialGroup { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}
