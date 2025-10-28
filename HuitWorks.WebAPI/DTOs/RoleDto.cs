using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class RoleDto
    {
        public string IdRole { get; set; } = null!;
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
    }

    public class CreateRoleDto
    {
        [Required(ErrorMessage = "Tên vai trò là bắt buộc.")]
        [StringLength(100, ErrorMessage = "Tên vai trò không được vượt quá 100 ký tự.")]
        public string RoleName { get; set; } = null!;

        [StringLength(200, ErrorMessage = "Mô tả không được vượt quá 200 ký tự.")]
        public string? Description { get; set; }
    }

    public class UpdateRoleDto
    {
        [Required(ErrorMessage = "Tên vai trò là bắt buộc.")]
        [StringLength(100, ErrorMessage = "Tên vai trò không được vượt quá 100 ký tự.")]
        public string RoleName { get; set; } = null!;

        [StringLength(200, ErrorMessage = "Mô tả không được vượt quá 200 ký tự.")]
        public string? Description { get; set; }
    }
}
