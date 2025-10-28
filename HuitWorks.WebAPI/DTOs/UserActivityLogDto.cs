using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class UserActivityLogDto
    {
        public string IdLog { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string ActionType { get; set; } = null!;
        public string? Description { get; set; }
        public string? EntityName { get; set; }
        public string? EntityId { get; set; }
        public string? IpAddress { get; set; }
        public string? UserAgent { get; set; }
        public DateTime CreatedAt { get; set; }
    }
    public class CreateUserActivityLogDto
    {
        [Required]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [StringLength(100)]
        public string ActionType { get; set; } = null!;

        public string? Description { get; set; }

        [StringLength(100)]
        public string? EntityName { get; set; }

        [StringLength(64)]
        public string? EntityId { get; set; }

        [StringLength(45)]
        public string? IpAddress { get; set; }

        [StringLength(255)]
        public string? UserAgent { get; set; }
    }

}
