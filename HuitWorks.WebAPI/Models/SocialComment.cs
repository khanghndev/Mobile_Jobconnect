using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialcomment")]
    public class SocialComment
    {
        [Key]
        [Column("idComment")]
        [StringLength(64)]
        public string IdComment { get; set; } = null!;

        [Required]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("parentComment")]
        [StringLength(64)]
        public string? ParentComment { get; set; }

        [Required]
        [Column("content", TypeName = "TEXT")]
        public string Content { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [Column("isDeleted")]
        public bool IsDeleted { get; set; } = false;

        [Column("deletedAt")]
        public DateTime? DeletedAt { get; set; }

        [Column("deletedBy")]
        [StringLength(64)]
        public string? DeletedBy { get; set; }

        [Column("likesCount")]
        public int LikesCount { get; set; } = 0;

        [Column("repliesCount")]
        public int RepliesCount { get; set; } = 0;

        [Column("isEdited")]
        public bool IsEdited { get; set; } = false;

        [Column("editedAt")]
        public DateTime? EditedAt { get; set; }

        [ForeignKey(nameof(IdPost))]
        public SocialPost? Post { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(ParentComment))]
        public SocialComment? Parent { get; set; }

        // Navigation properties
        public virtual ICollection<SocialCommentLike> Likes { get; set; } = new List<SocialCommentLike>();
        public virtual ICollection<SocialCommentReport> Reports { get; set; } = new List<SocialCommentReport>();
        public virtual ICollection<SocialComment> Replies { get; set; } = new List<SocialComment>();
    }

    [Table("socialcommentlikes")]
    public class SocialCommentLike
    {
        [Key]
        [Column("idLike")]
        [StringLength(64)]
        public string IdLike { get; set; } = null!;

        [Required]
        [Column("idComment")]
        [StringLength(64)]
        public string IdComment { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdComment))]
        public SocialComment? Comment { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }

    [Table("socialcommentreports")]
    public class SocialCommentReport
    {
        [Key]
        [Column("idReport")]
        [StringLength(64)]
        public string IdReport { get; set; } = null!;

        [Required]
        [Column("idComment")]
        [StringLength(64)]
        public string IdComment { get; set; } = null!;

        [Required]
        [Column("reporterId")]
        [StringLength(64)]
        public string ReporterId { get; set; } = null!;

        [Required]
        [Column("reason")]
        [StringLength(500)]
        public string Reason { get; set; } = null!;

        [Column("status")]
        [StringLength(20)]
        public string Status { get; set; } = "pending";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("reviewedAt")]
        public DateTime? ReviewedAt { get; set; }

        [Column("reviewedBy")]
        [StringLength(64)]
        public string? ReviewedBy { get; set; }

        [Column("notes", TypeName = "TEXT")]
        public string? Notes { get; set; }

        [ForeignKey(nameof(IdComment))]
        public SocialComment? Comment { get; set; }

        [ForeignKey(nameof(ReporterId))]
        public User? Reporter { get; set; }

        [ForeignKey(nameof(ReviewedBy))]
        public User? Reviewer { get; set; }
    }
}





