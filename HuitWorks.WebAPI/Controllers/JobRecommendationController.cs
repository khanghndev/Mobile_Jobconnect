using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Services;
using System.Security.Claims;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JobRecommendationController : ControllerBase
    {
        private readonly IJobRecommendationService _recommendationService;
        private readonly ILogger<JobRecommendationController> _logger;

        public JobRecommendationController(
            IJobRecommendationService recommendationService,
            ILogger<JobRecommendationController> logger)
        {
            _recommendationService = recommendationService;
            _logger = logger;
        }

        private string GetCurrentUserId()
        {
            return User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                   ?? User.FindFirst("sub")?.Value
                   ?? "";
        }

        /// <summary>
        /// Lấy danh sách công việc được gợi ý cá nhân hóa cho user
        /// </summary>
        [HttpGet("personalized")]
        [Authorize]
        public async Task<ActionResult<List<JobRecommendationDto>>> GetPersonalizedRecommendations(
            [FromQuery] string? preferredLocation = null,
            [FromQuery] decimal? maxDistanceKm = 50,
            [FromQuery] decimal? minSalary = null,
            [FromQuery] decimal? maxSalary = null,
            [FromQuery] string? preferredWorkType = null,
            [FromQuery] string? preferredExperienceLevel = null,
            [FromQuery] string? preferredSkills = null,
            [FromQuery] int limit = 10)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var request = new JobRecommendationRequestDto
                {
                    UserId = userId,
                    PreferredLocation = preferredLocation,
                    MaxDistanceKm = maxDistanceKm,
                    MinSalary = minSalary,
                    MaxSalary = maxSalary,
                    PreferredWorkType = preferredWorkType,
                    PreferredExperienceLevel = preferredExperienceLevel,
                    PreferredSkills = !string.IsNullOrEmpty(preferredSkills) 
                        ? preferredSkills.Split(',', StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => s.Trim()).ToList() 
                        : null,
                    Limit = Math.Min(limit, 50) // Max 50 recommendations
                };

                var recommendations = await _recommendationService.GetPersonalizedRecommendationsAsync(request);
                
                _logger.LogInformation("Retrieved {Count} personalized recommendations for user {UserId}", 
                    recommendations.Count, userId);

                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting personalized recommendations");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        /// <summary>
        /// Lấy dữ liệu trang chủ cá nhân hóa (cho user đã đăng nhập)
        /// </summary>
        [HttpGet("homepage")]
        [Authorize]
        public async Task<ActionResult<PersonalizedHomepageDto>> GetPersonalizedHomepage()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var homepageData = await _recommendationService.GetPersonalizedHomepageDataAsync(userId);
                
                _logger.LogInformation("Retrieved personalized homepage data for user {UserId}", userId);

                return Ok(homepageData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting personalized homepage data");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        /// <summary>
        /// Lấy danh sách kỹ năng đang trending
        /// </summary>
        [HttpGet("trending-skills")]
        [AllowAnonymous]
        public async Task<ActionResult<List<string>>> GetTrendingSkills([FromQuery] int limit = 10)
        {
            try
            {
                var skills = await _recommendationService.GetTrendingSkillsAsync(Math.Min(limit, 50));
                return Ok(skills);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting trending skills");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        /// <summary>
        /// Lấy danh sách địa điểm phổ biến
        /// </summary>
        [HttpGet("popular-locations")]
        [AllowAnonymous]
        public async Task<ActionResult<List<string>>> GetPopularLocations([FromQuery] int limit = 10)
        {
            try
            {
                var locations = await _recommendationService.GetPopularLocationsAsync(Math.Min(limit, 50));
                return Ok(locations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting popular locations");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        /// <summary>
        /// Tính điểm phù hợp giữa user và một công việc cụ thể
        /// </summary>
        [HttpGet("match-score/{jobId}")]
        [Authorize]
        public async Task<ActionResult<object>> GetJobMatchScore(string jobId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var matchScore = await _recommendationService.CalculateJobMatchScoreAsync(userId, jobId);
                
                return Ok(new 
                { 
                    JobId = jobId,
                    UserId = userId,
                    MatchScore = matchScore,
                    MatchPercentage = Math.Round(matchScore * 100, 1)
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating match score for job {JobId}", jobId);
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        /// <summary>
        /// Lấy dữ liệu trang chủ cho user chưa đăng nhập (public data)
        /// </summary>
        [HttpGet("homepage/public")]
        [AllowAnonymous]
        public async Task<ActionResult<object>> GetPublicHomepageData()
        {
            try
            {
                var trendingSkills = await _recommendationService.GetTrendingSkillsAsync(8);
                var popularLocations = await _recommendationService.GetPopularLocationsAsync(8);

                return Ok(new
                {
                    TrendingSkills = trendingSkills,
                    PopularLocations = popularLocations,
                    Message = "Đăng nhập để xem gợi ý công việc cá nhân hóa"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting public homepage data");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }
    }
}
