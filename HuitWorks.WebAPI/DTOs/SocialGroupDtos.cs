using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    // DTO cho tạo group mới
    public class CreateGroupDto
    {
        [Required(ErrorMessage = "ID người tạo là bắt buộc")]
        public string CreatedBy { get; set; } = null!;

        [Required(ErrorMessage = "Tên nhóm là bắt buộc")]
        [StringLength(255, ErrorMessage = "Tên nhóm không được vượt quá 255 ký tự")]
        public string GroupName { get; set; } = null!;

        [StringLength(1000, ErrorMessage = "Mô tả không được vượt quá 1000 ký tự")]
        public string? Description { get; set; }

        [Required(ErrorMessage = "Quyền riêng tư là bắt buộc")]
        [RegularExpression("^(public|private|hidden)$", ErrorMessage = "Quyền riêng tư phải là public, private hoặc hidden")]
        public string Privacy { get; set; } = "public";

        [StringLength(255, ErrorMessage = "URL ảnh bìa không được vượt quá 255 ký tự")]
        public string? CoverImageUrl { get; set; }

        public bool RequirePostApproval { get; set; } = true;

        public List<string>? Tags { get; set; }
    }

    // DTO cho cập nhật group
    public class UpdateGroupDto
    {
        [StringLength(255, ErrorMessage = "Tên nhóm không được vượt quá 255 ký tự")]
        public string? GroupName { get; set; }

        [StringLength(1000, ErrorMessage = "Mô tả không được vượt quá 1000 ký tự")]
        public string? Description { get; set; }

        [RegularExpression("^(public|private|hidden)$", ErrorMessage = "Quyền riêng tư phải là public, private hoặc hidden")]
        public string? Privacy { get; set; }

        [StringLength(255, ErrorMessage = "URL ảnh bìa không được vượt quá 255 ký tự")]
        public string? CoverImageUrl { get; set; }

        public bool? RequirePostApproval { get; set; }

        public List<string>? Tags { get; set; }
    }

    // DTO cho thông tin group
    public class GroupInfoDto
    {
        public string IdGroup { get; set; } = null!;
        public string GroupName { get; set; } = null!;
        public string? Description { get; set; }
        public string Privacy { get; set; } = null!;
        public string? CoverImageUrl { get; set; }
        public string CreatedBy { get; set; } = null!;
        public string? CreatorName { get; set; }
        public string? CreatorAvatar { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int MemberCount { get; set; }
        public int PostCount { get; set; }
        public List<string> Tags { get; set; } = new List<string>();
        public bool RequirePostApproval { get; set; } = true;
        public string? UserRole { get; set; } // Vai trò của user hiện tại trong group
        public string? UserStatus { get; set; } // Trạng thái của user hiện tại trong group
    }

    // DTO cho danh sách group
    public class GroupListItemDto
    {
        public string IdGroup { get; set; } = null!;
        public string GroupName { get; set; } = null!;
        public string? Description { get; set; }
        public string Privacy { get; set; } = null!;
        public string? CoverImageUrl { get; set; }
        public string? CreatorName { get; set; }
        public DateTime CreatedAt { get; set; }
        public int MemberCount { get; set; }
        public int PostCount { get; set; }
        public List<string> Tags { get; set; } = new List<string>();
        public bool RequirePostApproval { get; set; } = true;
        public string? UserRole { get; set; }
        public string? UserStatus { get; set; }
    }

    // DTO cho join group
    public class JoinGroupDto
    {
        [Required(ErrorMessage = "ID nhóm là bắt buộc")]
        public string IdGroup { get; set; } = null!;
    }

    // DTO cho leave group
    public class LeaveGroupDto
    {
        [Required(ErrorMessage = "ID nhóm là bắt buộc")]
        public string IdGroup { get; set; } = null!;
    }

    // DTO cho thay đổi vai trò member
    public class ChangeMemberRoleDto
    {
        [Required(ErrorMessage = "ID nhóm là bắt buộc")]
        public string IdGroup { get; set; } = null!;

        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Vai trò là bắt buộc")]
        [RegularExpression("^(owner|admin|moderator|member)$", ErrorMessage = "Vai trò phải là owner, admin, moderator hoặc member")]
        public string RoleInGroup { get; set; } = null!;
    }

    // DTO cho kick member
    public class KickMemberDto
    {
        [Required(ErrorMessage = "ID nhóm là bắt buộc")]
        public string IdGroup { get; set; } = null!;

        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string IdUser { get; set; } = null!;
    }

    // DTO cho danh sách members
    public class GroupMemberDto
    {
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? AvatarUrl { get; set; }
        public string RoleInGroup { get; set; } = null!;
        public string Status { get; set; } = null!;
        public DateTime JoinedAt { get; set; }
    }
}
