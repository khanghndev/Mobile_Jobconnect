using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("candidateSkills")]
    public class CandidateSkills
    {
        [Key]
        [Column("idSkill")]
        [StringLength(64)]
        public string IdSkill { get; set; } = string.Empty;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = string.Empty;

        [Required]
        [Column("skillName")]
        [StringLength(100)]
        public string SkillName { get; set; } = string.Empty;

        [Column("skillLevel")]
        [StringLength(20)]
        public string SkillLevel { get; set; } = "beginner";

        // Navigation property
        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}
