using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class RecruiterInfoDto
    {
        public string IdUser { get; set; } = null!;
        public string Title { get; set; } = null!;
        public string? IdCompany { get; set; }
        public string? Department { get; set; }
        public string? Description { get; set; }
    }

    public class CreateRecruiterInfoDto
    {
        [Required(ErrorMessage = "IdUser là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdUser không được vượt quá 64 ký tự.")]
        public string IdUser { get; set; } = null!;

        //[Required(ErrorMessage = "Chức danh (Title) là bắt buộc.")]
        [StringLength(100, ErrorMessage = "Title không được vượt quá 100 ký tự.")]
        public string Title { get; set; } = null!;

        [StringLength(64, ErrorMessage = "IdCompany không được vượt quá 64 ký tự.")]
        public string? IdCompany { get; set; }

        [StringLength(100, ErrorMessage = "Department không được vượt quá 100 ký tự.")]
        public string? Department { get; set; }

        public string? Description { get; set; }
    }

    public class UpdateRecruiterInfoDto
    {
        [StringLength(100, ErrorMessage = "Title không được vượt quá 100 ký tự.")]
        public string? Title { get; set; }

        [StringLength(64, ErrorMessage = "IdCompany không được vượt quá 64 ký tự.")]
        public string? IdCompany { get; set; }

        [StringLength(100, ErrorMessage = "Department không được vượt quá 100 ký tự.")]
        public string? Department { get; set; }

        public string? Description { get; set; }
    }
}
