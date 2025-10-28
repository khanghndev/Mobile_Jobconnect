using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("social_follow")]
    public class SocialFollow
    {
        [Key]
        [Column("followerId")]
        [StringLength(64)]
        public string FollowerId { get; set; } = null!;

        [Key]
        [Column("followingId")]
        [StringLength(64)]
        public string FollowingId { get; set; } = null!;

        [Column("followType", TypeName = "enum('normal', 'close_friend')")]
        [StringLength(20)]
        public string FollowType { get; set; } = "normal";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(FollowerId))]
        public User? Follower { get; set; }

        [ForeignKey(nameof(FollowingId))]
        public User? Following { get; set; }
    }
}

