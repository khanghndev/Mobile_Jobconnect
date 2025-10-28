using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class CandidateSkillsDto
    {
        public string IdSkill { get; set; } = string.Empty;
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên kỹ năng là bắt buộc")]
        [StringLength(100, ErrorMessage = "Tên kỹ năng không được vượt quá 100 ký tự")]
        public string SkillName { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Cấp độ kỹ năng là bắt buộc")]
        public string SkillLevel { get; set; } = "beginner";
    }

    public class CreateCandidateSkillsDto
    {
        [Required(ErrorMessage = "ID người dùng là bắt buộc")]
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên kỹ năng là bắt buộc")]
        [StringLength(100, ErrorMessage = "Tên kỹ năng không được vượt quá 100 ký tự")]
        public string SkillName { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Cấp độ kỹ năng là bắt buộc")]
        public string SkillLevel { get; set; } = "beginner";
    }

    public class UpdateCandidateSkillsDto
    {
        [Required(ErrorMessage = "ID kỹ năng là bắt buộc")]
        public string IdSkill { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Tên kỹ năng là bắt buộc")]
        [StringLength(100, ErrorMessage = "Tên kỹ năng không được vượt quá 100 ký tự")]
        public string SkillName { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Cấp độ kỹ năng là bắt buộc")]
        public string SkillLevel { get; set; } = "beginner";
    }
}
