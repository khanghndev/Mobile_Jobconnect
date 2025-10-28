using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class NewsDto
    {
        public int IdNews { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
        public string? Summary { get; set; }
        public string? ImageUrl { get; set; }
        public DateTime PublishDate { get; set; }
        public string? Author { get; set; }
        public bool IsPublished { get; set; }
        public string? CategoryName { get; set; }
        public string? TargetAudience { get; set; }
    }

    public class CreateNewsDto
    {
        [Required]
        [StringLength(255)]
        public required string Title { get; set; }

        [Required]
        public required string Content { get; set; }

        [StringLength(500)]
        public string? Summary { get; set; }

        [StringLength(255)]
        public string? ImageUrl { get; set; }

        [Required]
        public DateTime PublishDate { get; set; }

        [StringLength(100)]
        public string? Author { get; set; }

        public bool IsPublished { get; set; } = false;

        [Required]
        [StringLength(100)]
        public required string CategoryName { get; set; }

        [Required]
        [StringLength(20)]
        public string TargetAudience { get; set; } = "All";
    }

    public class UpdateNewsDto : CreateNewsDto { }
}
