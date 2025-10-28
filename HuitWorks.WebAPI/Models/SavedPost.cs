using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("saved_posts")]
    public class SavedPost
    {
        [Key]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Key]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("savedAt")]
        public DateTime SavedAt { get; set; } = DateTime.UtcNow;

        [Column("folderName")]
        [StringLength(100)]
        public string FolderName { get; set; } = "All Posts";

        [Column("note", TypeName = "TEXT")]
        public string? Note { get; set; }

        // Navigation properties
        [ForeignKey(nameof(IdPost))]
        public SocialPost? Post { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}

