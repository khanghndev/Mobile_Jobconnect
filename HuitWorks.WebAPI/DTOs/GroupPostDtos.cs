using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    // DTO cho tạo bài đăng trong group
    public class CreateGroupPostDto
    {
        [Required(ErrorMessage = "ID nhóm là bắt buộc")]
        public string IdGroup { get; set; } = null!;

        [Required(ErrorMessage = "ID người đăng là bắt buộc")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Nội dung bài đăng là bắt buộc")]
        [StringLength(5000, ErrorMessage = "Nội dung không được vượt quá 5000 ký tự")]
        public string Content { get; set; } = null!;

        public string? MediaUrl { get; set; }

        [Required(ErrorMessage = "Loại bài đăng là bắt buộc")]
        [RegularExpression("^(text|image|video|link)$", ErrorMessage = "Loại bài đăng phải là text, image, video hoặc link")]
        public string PostType { get; set; } = "text";
    }

    // DTO cho cập nhật bài đăng
    public class UpdateGroupPostDto
    {
        [StringLength(5000, ErrorMessage = "Nội dung không được vượt quá 5000 ký tự")]
        public string? Content { get; set; }

        public string? MediaUrl { get; set; }

        [RegularExpression("^(text|image|video|link)$", ErrorMessage = "Loại bài đăng phải là text, image, video hoặc link")]
        public string? PostType { get; set; }
    }

    // DTO cho thông tin bài đăng
    public class GroupPostDto
    {
        public string IdPost { get; set; } = null!;
        public string IdGroup { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? UserAvatar { get; set; }
        public string Content { get; set; } = null!;
        public string? MediaUrl { get; set; }
        public string PostType { get; set; } = null!;
        public string ApprovalStatus { get; set; } = "pending";
        public string? ApprovedBy { get; set; }
        public string? ApproverName { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int CommentCount { get; set; }
        public int ReactionCount { get; set; }
        public List<GroupReactionDto> Reactions { get; set; } = new List<GroupReactionDto>();
        public List<GroupCommentDto> Comments { get; set; } = new List<GroupCommentDto>();
        public bool IsLikedByUser { get; set; }
        public string? UserReaction { get; set; }
    }

    // DTO cho danh sách bài đăng
    public class GroupPostListItemDto
    {
        public string IdPost { get; set; } = null!;
        public string IdGroup { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? UserAvatar { get; set; }
        public string Content { get; set; } = null!;
        public string? MediaUrl { get; set; }
        public string PostType { get; set; } = null!;
        public string ApprovalStatus { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
        public int CommentCount { get; set; }
        public int ReactionCount { get; set; }
        public bool IsLikedByUser { get; set; }
        public string? UserReaction { get; set; }
    }

    // DTO cho tạo comment
    public class CreateGroupCommentDto
    {
        [Required(ErrorMessage = "ID bài đăng là bắt buộc")]
        public string IdPost { get; set; } = null!;

        [Required(ErrorMessage = "ID người bình luận là bắt buộc")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Nội dung bình luận là bắt buộc")]
        [StringLength(2000, ErrorMessage = "Nội dung bình luận không được vượt quá 2000 ký tự")]
        public string Content { get; set; } = null!;

        public string? ParentId { get; set; } // ID của comment cha (để reply)
    }

    // DTO cho cập nhật comment
    public class UpdateGroupCommentDto
    {
        [StringLength(2000, ErrorMessage = "Nội dung bình luận không được vượt quá 2000 ký tự")]
        public string? Content { get; set; }
    }

    // DTO cho thông tin comment
    public class GroupCommentDto
    {
        public string IdComment { get; set; } = null!;
        public string IdPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? UserAvatar { get; set; }
        public string Content { get; set; } = null!;
        public string? ParentId { get; set; }
        public DateTime CreatedAt { get; set; }
        public int ReplyCount { get; set; }
        public int ReactionCount { get; set; }
        public List<GroupReactionDto> Reactions { get; set; } = new List<GroupReactionDto>();
        public List<GroupCommentDto> Replies { get; set; } = new List<GroupCommentDto>();
        public bool IsLikedByUser { get; set; }
        public string? UserReaction { get; set; }
    }

    // DTO cho reaction
    public class CreateGroupReactionDto
    {
        [Required(ErrorMessage = "Loại entity là bắt buộc")]
        [RegularExpression("^(post|comment)$", ErrorMessage = "Loại entity phải là post hoặc comment")]
        public string EntityType { get; set; } = null!;

        [Required(ErrorMessage = "ID entity là bắt buộc")]
        public string EntityId { get; set; } = null!;

        [Required(ErrorMessage = "ID người dùng là bắt buộc")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Loại reaction là bắt buộc")]
        [RegularExpression("^(like|love|haha|wow|sad|angry)$", ErrorMessage = "Loại reaction không hợp lệ")]
        public string Reaction { get; set; } = "like";
    }

    // DTO cho thông tin reaction
    public class GroupReactionDto
    {
        public string IdReaction { get; set; } = null!;
        public string EntityType { get; set; } = null!;
        public string EntityId { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? UserAvatar { get; set; }
        public string Reaction { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }

    // DTO cho xóa reaction
    public class RemoveGroupReactionDto
    {
        [Required(ErrorMessage = "Loại entity là bắt buộc")]
        [RegularExpression("^(post|comment)$", ErrorMessage = "Loại entity phải là post hoặc comment")]
        public string EntityType { get; set; } = null!;

        [Required(ErrorMessage = "ID entity là bắt buộc")]
        public string EntityId { get; set; } = null!;
    }

    // DTO cho duyệt bài đăng
    public class ApproveGroupPostDto
    {
        [Required(ErrorMessage = "ID bài đăng là bắt buộc")]
        public string IdPost { get; set; } = null!;

        [Required(ErrorMessage = "ID người duyệt là bắt buộc")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Trạng thái duyệt là bắt buộc")]
        [RegularExpression("^(approved|rejected)$", ErrorMessage = "Trạng thái duyệt phải là approved hoặc rejected")]
        public string ApprovalStatus { get; set; } = null!;

        [StringLength(500, ErrorMessage = "Lý do không được vượt quá 500 ký tự")]
        public string? Reason { get; set; }
    }

    // DTO cho danh sách bài đăng chờ duyệt
    public class PendingPostDto
    {
        public string IdPost { get; set; } = null!;
        public string IdGroup { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string? UserName { get; set; }
        public string? UserAvatar { get; set; }
        public string Content { get; set; } = null!;
        public string? MediaUrl { get; set; }
        public string PostType { get; set; } = null!;
        public string ApprovalStatus { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
        public int CommentCount { get; set; }
        public int ReactionCount { get; set; }
    }

}
