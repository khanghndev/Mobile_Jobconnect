using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Services
{
    public interface IJobRecommendationService
    {
        Task<List<JobRecommendationDto>> GetPersonalizedRecommendationsAsync(JobRecommendationRequestDto request);
        Task<PersonalizedHomepageDto> GetPersonalizedHomepageDataAsync(string userId);
        Task<List<string>> GetTrendingSkillsAsync(int limit = 10);
        Task<List<string>> GetPopularLocationsAsync(int limit = 10);
        Task<double> CalculateJobMatchScoreAsync(string userId, string jobId);
    }
}
