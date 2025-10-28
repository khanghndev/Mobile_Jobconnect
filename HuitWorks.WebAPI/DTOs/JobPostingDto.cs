// DTOs/JobPostingDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class JobPostingDto
    {
        public string IdJobPost { get; set; } = null!;
        public string Title { get; set; } = null!;
        public string Description { get; set; } = null!;
        public string? Requirements { get; set; } // Cho phép null
        public decimal? Salary { get; set; }
        public string Location { get; set; } = null!;
        public decimal? Latitude { get; set; }   // Thêm Latitude
        public decimal? Longitude { get; set; }  // Thêm Longitude
        public string WorkType { get; set; } = null!;
        public string ExperienceLevel { get; set; } = null!;
        public string IdCompany { get; set; } = null!;
        public DateTime? ApplicationDeadline { get; set; }
        public string? Benefits { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int IsFeatured { get; set; }
        public string PostStatus { get; set; } = null!;
        public CompanyDto? Company { get; set; } // Thêm Company DTO nếu muốn trả về thông tin công ty
    }

    public class CreateJobPostingDto
    {
        [Required(ErrorMessage = "Title là bắt buộc.")]
        [StringLength(100, ErrorMessage = "Tiêu đề không được vượt quá 100 ký tự.")] // Giới hạn độ dài
        public string Title { get; set; } = null!;

        [Required(ErrorMessage = "Description là bắt buộc.")]
        public string Description { get; set; } = null!;

        public string? Requirements { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Salary phải >= 0.")]
        public decimal? Salary { get; set; }

        [Required(ErrorMessage = "Location là bắt buộc.")]
        [StringLength(255, ErrorMessage = "Địa điểm không được vượt quá 255 ký tự.")]
        public string Location { get; set; } = null!;

        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }

        [Required(ErrorMessage = "WorkType là bắt buộc.")]
        [StringLength(50)]
        public string WorkType { get; set; } = null!;

        [Required(ErrorMessage = "ExperienceLevel là bắt buộc.")]
        [StringLength(50)]
        public string ExperienceLevel { get; set; } = null!;

        [Required(ErrorMessage = "IdCompany là bắt buộc.")]
        [StringLength(64)]
        public string IdCompany { get; set; } = null!;

        public DateTime? ApplicationDeadline { get; set; }

        public string? Benefits { get; set; }
    }

    public class UpdateJobPostingDto
    {
        [StringLength(100, ErrorMessage = "Tiêu đề không được vượt quá 100 ký tự.")]
        public string? Title { get; set; }

        public string? Description { get; set; }
        public string? Requirements { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Salary phải >= 0.")]
        public decimal? Salary { get; set; }

        [StringLength(255, ErrorMessage = "Địa điểm không được vượt quá 255 ký tự.")]
        public string? Location { get; set; } // Địa chỉ đầy đủ dạng text

        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }

        [StringLength(50)]
        public string? WorkType { get; set; }

        [StringLength(50, ErrorMessage = "Trình độ kinh nghiệm không được vượt quá 50 ký tự.")]
        public string? ExperienceLevel { get; set; }

        [StringLength(64, ErrorMessage = "IdCompany không được vượt quá 64 ký tự.")]
        public string? IdCompany { get; set; }

        public DateTime? ApplicationDeadline { get; set; }
        public string? Benefits { get; set; }

        [RegularExpression("^(open|closed|waiting|editing)$", ErrorMessage = "PostStatus chỉ nhận các giá trị: open, closed, waiting, editing.")]
        public string? PostStatus { get; set; }
    }

    // DTOs for spatial queries
    public class NearbyJobsRequestDto
    {
        [Required(ErrorMessage = "Latitude là bắt buộc.")]
        [Range(-90, 90, ErrorMessage = "Latitude phải nằm trong khoảng -90 đến 90.")]
        public decimal Latitude { get; set; }

        [Required(ErrorMessage = "Longitude là bắt buộc.")]
        [Range(-180, 180, ErrorMessage = "Longitude phải nằm trong khoảng -180 đến 180.")]
        public decimal Longitude { get; set; }

        [Required(ErrorMessage = "Radius là bắt buộc.")]
        [Range(0.1, 100, ErrorMessage = "Radius phải nằm trong khoảng 0.1 đến 100 km.")]
        public decimal RadiusKm { get; set; } = 10; // Default 10km radius

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }

    public class AreaJobsRequestDto
    {
        [Required(ErrorMessage = "Polygon coordinates are required.")]
        [MinLength(3, ErrorMessage = "Polygon phải có ít nhất 3 điểm.")]
        public List<PointDto> Polygon { get; set; } = new();
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }

    public class PointDto
    {
        [Required(ErrorMessage = "Latitude là bắt buộc.")]
        [Range(-90, 90, ErrorMessage = "Latitude phải nằm trong khoảng -90 đến 90.")]
        public decimal Latitude { get; set; }

        [Required(ErrorMessage = "Longitude là bắt buộc.")]
        [Range(-180, 180, ErrorMessage = "Longitude phải nằm trong khoảng -180 đến 180.")]
        public decimal Longitude { get; set; }
    }

    public class JobPostingWithDistanceDto : JobPostingDto
    {
        public decimal? DistanceKm { get; set; }
    }
}
