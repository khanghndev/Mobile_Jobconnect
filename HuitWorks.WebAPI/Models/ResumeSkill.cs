using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.Models
{
    [Table("resumeSkill")]
    public class ResumeSkill
    {
        [Key]
        [Column("idResume")]
        [StringLength(64)]
        public required string IdResume { get; set; }

        [Key]
        [Column("skills")]
        [StringLength(255)]
        public required string Skill { get; set; }

        [Column("proficiency")]
        [StringLength(64)]
        public string? Proficiency { get; set; }
    }
}
