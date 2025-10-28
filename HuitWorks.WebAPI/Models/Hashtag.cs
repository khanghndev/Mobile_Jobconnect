using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("hashtag")]
    public class Hashtag
    {
        [Key]
        [Column("idHashtag")]
        public long IdHashtag { get; set; }

        [Required]
        [Column("tag_original")]
        [StringLength(64)]
        public string TagOriginal { get; set; } = null!;

        [Required]
        [Column("slug")]
        [StringLength(64)]
        public string Slug { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}


