using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("candidateInfo")]
    public class CandidateInfo
    {
        [Key]
        [Column("idUser")]
        public required string IdUser { get; set; }

        [Column("workPosition")]
        public string? WorkPosition { get; set; }

        [Column("ratingScore")]
        public decimal? RatingScore { get; set; }

        [Column("universityName")]
        public string? UniversityName { get; set; }

        [Column("educationLevel")]
        public string? EducationLevel { get; set; }

        [Column("experienceYears")]
        public int? ExperienceYears { get; set; }

        [Column("skills")]
        public string? Skills { get; set; }

        [Column("freeTime")]
        [StringLength(2000)]
        public string? FreeTime { get; set; }

        [Column("portfolioUrl")]
        public string? PortfolioUrl { get; set; }

    }
}
