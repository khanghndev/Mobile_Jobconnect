using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class WebsiteDto
    {
        public string IdWebsite { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string Url { get; set; } = null!;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateWebsiteDto
    {
        [Required(ErrorMessage = "Tên website là bắt buộc.")]
        [StringLength(255, ErrorMessage = "Tên không được vượt quá 255 ký tự.")]
        public string Name { get; set; } = null!;

        [Required(ErrorMessage = "URL là bắt buộc.")]
        [StringLength(2083, ErrorMessage = "URL không được vượt quá 2083 ký tự.")]
        public string Url { get; set; } = null!;

        [StringLength(500, ErrorMessage = "Mô tả không được vượt quá 500 ký tự.")]
        public string? Description { get; set; }
    }

    public class UpdateWebsiteDto
    {
        [StringLength(255, ErrorMessage = "Tên không được vượt quá 255 ký tự.")]
        public string? Name { get; set; }

        [StringLength(2083, ErrorMessage = "URL không được vượt quá 2083 ký tự.")]
        public string? Url { get; set; }

        [StringLength(500, ErrorMessage = "Mô tả không được vượt quá 500 ký tự.")]
        public string? Description { get; set; }

        public bool? IsActive { get; set; }
    }
}
