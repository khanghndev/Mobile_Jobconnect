// File: Models/JobPosting.cs
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("jobPosting")]
    public class JobPosting
    {
        [Key]
        [Column("idJobPost")]
        [StringLength(64)]
        public string IdJobPost { get; set; } = null!;

        [Required]
        [Column("title")]
        [StringLength(255)] // Nên giảm xuống 100-150 nếu database definition là VARCHAR(100)
        public string Title { get; set; } = null!;

        [Required]
        [Column("description", TypeName = "TEXT")]
        public string Description { get; set; } = null!;

        [Column("requirements", TypeName = "TEXT")]
        public string? Requirements { get; set; }

        [Column("salary", TypeName = "DECIMAL(18,2)")] // Giữ nguyên, tốt
        public decimal? Salary { get; set; } // Cho phép nullable nếu salary có thể không có

        [Required]
        [Column("location")]
        [StringLength(255)]
        public string Location { get; set; } = null!; // Địa chỉ đầy đủ dưới dạng text

        // Sửa đổi cho latitude và longitude
        [Column("latitude", TypeName = "DECIMAL(10,8)")] // Định nghĩa kiểu dữ liệu SQL chính xác
        public decimal? Latitude { get; set; } // Cho phép nullable, đổi tên thành PascalCase

        [Column("longitude", TypeName = "DECIMAL(11,8)")] // Định nghĩa kiểu dữ liệu SQL chính xác
        public decimal? Longitude { get; set; } // Cho phép nullable, đổi tên thành PascalCase

        [Required]
        [Column("workType")]
        [StringLength(50)]
        public string WorkType { get; set; } = null!;

        [Required]
        [Column("experienceLevel")]
        [StringLength(50)]
        public string ExperienceLevel { get; set; } = null!;

        [Required]
        [Column("idCompany")]
        [StringLength(64)]
        public string IdCompany { get; set; } = null!;

        [Column("applicationDeadline")] // Cho phép nullable nếu hạn chót có thể không bắt buộc
        public DateTime? ApplicationDeadline { get; set; }

        [Column("benefits", TypeName = "TEXT")]
        public string? Benefits { get; set; }

        [Required]
        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        [Required]
        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; }

        [Required]
        [Column("postStatus")]
        [StringLength(20)]
        public string PostStatus { get; set; } = null!;

        [Required]
        [Column("isFeatured")]
        public int IsFeatured { get; set; } // Hoặc bool IsFeatured { get; set; } nếu database hỗ trợ BIT/BOOLEAN

        [ForeignKey(nameof(IdCompany))]
        public Company? Company { get; set; }
    }
}