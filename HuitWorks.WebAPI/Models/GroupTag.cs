using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("group_tags")]
    public class GroupTag
    {
        [Key]
        [Column("idGroup")]
        [StringLength(64)]
        public string IdGroup { get; set; } = null!;

        [Key]
        [Column("tagName")]
        [StringLength(50)]
        public string TagName { get; set; } = null!;

        // Navigation properties
        [ForeignKey(nameof(IdGroup))]
        public SocialGroup? SocialGroup { get; set; }
    }
}
