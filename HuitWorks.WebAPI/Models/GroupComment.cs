using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("group_comments")]
    public class GroupComment
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

        [Required]
        [Column("content", TypeName = "TEXT")]
        public string Content { get; set; } = null!;

        [Column("parentId")]
        [StringLength(64)]
        public string? ParentId { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey(nameof(IdPost))]
        public GroupPost? GroupPost { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(ParentId))]
        public GroupComment? ParentComment { get; set; }

        public virtual ICollection<GroupComment> Replies { get; set; } = new List<GroupComment>();
        
        // Không dùng navigation property GroupReactions vì không có foreign key trực tiếp
        // GroupReactions được query thủ công qua EntityType và EntityId
    }
}
