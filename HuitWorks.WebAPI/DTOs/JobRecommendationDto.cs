using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class JobRecommendationDto
    {
        public string IdJobPost { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? Requirements { get; set; } = string.Empty;
        public decimal? Salary { get; set; }
        public string Location { get; set; } = string.Empty;
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string WorkType { get; set; } = string.Empty;
        public string ExperienceLevel { get; set; } = string.Empty;
        public string IdCompany { get; set; } = string.Empty;
        public DateTime? ApplicationDeadline { get; set; }
        public string? Benefits { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int IsFeatured { get; set; }
        public string PostStatus { get; set; } = string.Empty;
        public CompanyDto? Company { get; set; }
        
        // Recommendation specific fields
        public double MatchScore { get; set; }
        public string MatchReason { get; set; } = string.Empty;
        public List<string> MatchedSkills { get; set; } = new List<string>();
        public double? DistanceKm { get; set; }
    }

    public class JobRecommendationRequestDto
    {
        [Required]
        public string UserId { get; set; } = string.Empty;
        public string? PreferredLocation { get; set; }
        public decimal? MaxDistanceKm { get; set; } = 50; // Default 50km radius
        public decimal? MinSalary { get; set; }
        public decimal? MaxSalary { get; set; }
        public string? PreferredWorkType { get; set; }
        public string? PreferredExperienceLevel { get; set; }
        public List<string>? PreferredSkills { get; set; }
        public int Limit { get; set; } = 10; // Default 10 recommendations
    }

    public class PersonalizedHomepageDto
    {
        public List<JobRecommendationDto> RecommendedJobs { get; set; } = new List<JobRecommendationDto>();
        public List<JobPostingDto> FeaturedJobs { get; set; } = new List<JobPostingDto>();
        public List<CompanyDto> FeaturedCompanies { get; set; } = new List<CompanyDto>();
        public UserPreferenceDto? UserPreferences { get; set; }
        public List<string> TrendingSkills { get; set; } = new List<string>();
        public List<string> PopularLocations { get; set; } = new List<string>();
    }

    public class UserPreferenceDto
    {
        public string? PreferredLocation { get; set; }
        public List<string> Skills { get; set; } = new List<string>();
        public string? WorkPosition { get; set; }
        public int? ExperienceYears { get; set; }
        public decimal? ExpectedSalary { get; set; }
        public string? PreferredWorkType { get; set; }
    }
}
