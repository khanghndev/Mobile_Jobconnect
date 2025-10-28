using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class ResumeSkillDto
    {
        public string IdResume { get; set; } = null!;
        public string Skill { get; set; } = null!;
        public string? Proficiency { get; set; }
    }

    public class CreateResumeSkillDto
    {
        [Required(ErrorMessage = "IdResume là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdResume không được vượt quá 64 ký tự.")]
        public string IdResume { get; set; } = null!;

        [Required(ErrorMessage = "Skill là bắt buộc.")]
        [StringLength(255, ErrorMessage = "Skill không được vượt quá 255 ký tự.")]
        public string Skill { get; set; } = null!;

        [StringLength(64, ErrorMessage = "Proficiency không được vượt quá 64 ký tự.")]
        public string? Proficiency { get; set; }
    }

    public class UpdateResumeSkillDto
    {
        [Required(ErrorMessage = "IdResume là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdResume không được vượt quá 64 ký tự.")]
        public string IdResume { get; set; } = null!;

        [Required(ErrorMessage = "Skill là bắt buộc.")]
        [StringLength(255, ErrorMessage = "Skill không được vượt quá 255 ký tự.")]
        public string Skill { get; set; } = null!;

        [StringLength(64, ErrorMessage = "Proficiency không được vượt quá 64 ký tự.")]
        public string? Proficiency { get; set; }
    }
}
