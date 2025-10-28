using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("userActivityLog")]
    public class UserActivityLog
    {
        [Key]
        [Column("idLog")]
        [StringLength(64)]
        public string IdLog { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("actionType")]
        [StringLength(100)]
        public string ActionType { get; set; } = null!;

        [Column("description", TypeName = "TEXT")]
        public string? Description { get; set; }

        [Column("entityName")]
        [StringLength(100)]
        public string? EntityName { get; set; }

        [Column("entityId")]
        [StringLength(64)]
        public string? EntityId { get; set; }

        [Column("ipAddress")]
        [StringLength(45)]
        public string? IpAddress { get; set; }

        [Column("userAgent")]
        [StringLength(255)]
        public string? UserAgent { get; set; }

        [Required]
        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        // Navigation property (nếu cần liên kết tới Users)
        [ForeignKey("IdUser")]
        public User? User { get; set; }
    }
}
