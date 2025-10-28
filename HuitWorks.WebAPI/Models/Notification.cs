using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("notifications")]
    public class Notification
    {
        [Key]
        [Column("idNotification")]
        public string IdNotification { get; set; } = null!;

        [Column("idUser")]
        public string IdUser { get; set; } = null!;

        [Column("title")]
        [Required(ErrorMessage = "Tiêu đề là bắt buộc.")]
        public string Title { get; set; } = null!;

        [Column("type", TypeName = "enum('Cập nhật ứng tuyển','Phỏng vấn','Việc làm mới')")]
        public string Type { get; set; } = null!;

        [Column("dateTime")]
        public DateTime DateTime { get; set; }

        [Column("status", TypeName = "enum('Đã gửi','Lên lịch','Chờ xử lý', 'Đã xử lý')")]
        public string Status { get; set; } = null!;

        [Column("actionUrl")]
        public string? ActionUrl { get; set; }

        [Column("createdAt")]
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("isRead")]
        [Required]
        public int IsRead { get; set; } = 0;
    }
}
