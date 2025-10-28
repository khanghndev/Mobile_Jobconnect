using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("social_groups")]
    public class SocialGroup
    {
        [Key]
        [Column("idGroup")]
        [StringLength(64)]
        public string IdGroup { get; set; } = null!;

        [Required]
        [Column("groupName")]
        [StringLength(255)]
        public string GroupName { get; set; } = null!;

        [Column("description", TypeName = "TEXT")]
        public string? Description { get; set; }

        [Required]
        [Column("privacy", TypeName = "enum('public','private','hidden')")]
        [StringLength(10)]
        public string Privacy { get; set; } = "public";

        [Column("coverImageUrl")]
        [StringLength(255)]
        public string? CoverImageUrl { get; set; }

        [Required]
        [Column("createdBy")]
        [StringLength(64)]
        public string CreatedBy { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [Column("requirePostApproval")]
        public bool RequirePostApproval { get; set; } = true;

        // Navigation properties
        [ForeignKey(nameof(CreatedBy))]
        public User? Creator { get; set; }

        public virtual ICollection<GroupMember> GroupMembers { get; set; } = new List<GroupMember>();
        public virtual ICollection<GroupPost> GroupPosts { get; set; } = new List<GroupPost>();
        public virtual ICollection<GroupTag> GroupTags { get; set; } = new List<GroupTag>();
    }
}
