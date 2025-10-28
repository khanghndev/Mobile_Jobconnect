// DTOs/NotificationDTOs.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class NotificationDto
    {
        public string IdNotification { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string Title { get; set; } = null!;
        public string Type { get; set; } = null!;
        public DateTime DateTime { get; set; }
        public string Status { get; set; } = null!;
        public string? ActionUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public int IsRead { get; set; }
    }

    public class CreateNotificationDto
    {
        [Required(ErrorMessage = "IdUser là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdUser không được vượt quá 64 ký tự.")]
        public string IdUser { get; set; } = null!;

        [Required(ErrorMessage = "Tiêu đề là bắt buộc.")]
        [StringLength(255, ErrorMessage = "Tiêu đề không được vượt quá 255 ký tự.")]
        public string Title { get; set; } = null!;

        [Required(ErrorMessage = "Loại thông báo là bắt buộc.")]
        [RegularExpression("^(Cập nhật ứng tuyển|Phỏng vấn|Việc làm mới|Ứng tuyển)$",
            ErrorMessage = "Loại thông báo không hợp lệ.")]
        public string Type { get; set; } = null!;

        [Required(ErrorMessage = "Thời gian là bắt buộc.")]
        public DateTime DateTime { get; set; }

        [Required(ErrorMessage = "Trạng thái là bắt buộc.")]
        [RegularExpression("^(Đã gửi|Lên lịch|Chờ xử lý|Đã xử lý)$",
            ErrorMessage = "Trạng thái không hợp lệ.")]
        public string Status { get; set; } = null!;

        [StringLength(255, ErrorMessage = "ActionUrl không được vượt quá 255 ký tự.")]
        public string? ActionUrl { get; set; }

        [Range(0, 1, ErrorMessage = "IsRead chỉ nhận giá trị 0 hoặc 1.")]
        public int IsRead { get; set; } = 0;
    }

    public class UpdateNotificationDto
    {
        [StringLength(255, ErrorMessage = "Tiêu đề không được vượt quá 255 ký tự.")]
        public string? Title { get; set; }

        [RegularExpression("^(Cập nhật ứng tuyển|Phỏng vấn|Việc làm mới|Ứng tuyển)$",
            ErrorMessage = "Loại thông báo không hợp lệ.")]
        public string? Type { get; set; }

        public DateTime? DateTime { get; set; }

        [RegularExpression("^(Đã gửi|Lên lịch|Chờ xử lý|Đã xử lý)$",
            ErrorMessage = "Trạng thái không hợp lệ.")]
        public string? Status { get; set; }

        [StringLength(255, ErrorMessage = "ActionUrl không được vượt quá 255 ký tự.")]
        public string? ActionUrl { get; set; }

        [Range(0, 1, ErrorMessage = "IsRead chỉ nhận giá trị 0 hoặc 1.")]
        public int? IsRead { get; set; }
    }
}
