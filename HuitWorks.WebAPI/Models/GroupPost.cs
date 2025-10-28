using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("group_posts")]
    public class GroupPost
    {
        [Key]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Required]
        [Column("idGroup")]
        [StringLength(64)]
        public string IdGroup { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("content", TypeName = "TEXT")]
        public string Content { get; set; } = null!;

        [Column("mediaUrl")]
        [StringLength(255)]
        public string? MediaUrl { get; set; }

        [Required]
        [Column("postType", TypeName = "enum('text','image','video','link')")]
        [StringLength(10)]
        public string PostType { get; set; } = "text";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        [Column("approvalStatus", TypeName = "enum('pending','approved','rejected')")]
        [StringLength(10)]
        public string ApprovalStatus { get; set; } = "pending";

        [Column("approvedBy")]
        [StringLength(64)]
        public string? ApprovedBy { get; set; }

        [Column("approvedAt")]
        public DateTime? ApprovedAt { get; set; }

        // Navigation properties
        [ForeignKey(nameof(IdGroup))]
        public SocialGroup? SocialGroup { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(ApprovedBy))]
        public User? Approver { get; set; }

        public virtual ICollection<GroupComment> GroupComments { get; set; } = new List<GroupComment>();
        public virtual ICollection<GroupReaction> GroupReactions { get; set; } = new List<GroupReaction>();
    }
}
