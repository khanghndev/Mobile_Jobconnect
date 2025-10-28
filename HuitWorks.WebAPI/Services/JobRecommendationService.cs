using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

namespace HuitWorks.WebAPI.Services
{
    public class JobRecommendationService : IJobRecommendationService
    {
        private readonly JobConnectDbContext _context;
        private readonly IGeocodingService _geocodingService;
        private readonly ILogger<JobRecommendationService> _logger;

        public JobRecommendationService(
            JobConnectDbContext context,
            IGeocodingService geocodingService,
            ILogger<JobRecommendationService> logger)
        {
            _context = context;
            _geocodingService = geocodingService;
            _logger = logger;
        }

        public async Task<List<JobRecommendationDto>> GetPersonalizedRecommendationsAsync(JobRecommendationRequestDto request)
        {
            try
            {
                // Lấy thông tin user và candidate
                var user = await _context.Users.FindAsync(request.UserId);
                var candidate = await _context.CandidateInfo
                    .FirstOrDefaultAsync(c => c.IdUser == request.UserId);

                if (user == null)
                {
                    _logger.LogWarning("User not found: {UserId}", request.UserId);
                    return new List<JobRecommendationDto>();
                }

                // Lấy danh sách job phù hợp
                var jobs = await _context.JobPostings
                    .Where(jp => jp.PostStatus == "open" && 
                                (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow))
                    .Include(jp => jp.Company)
                    .ToListAsync();

                var recommendations = new List<JobRecommendationDto>();

                foreach (var job in jobs)
                {
                    var matchScore = await CalculateJobMatchScoreAsync(request.UserId, job.IdJobPost);
                    
                    // Chỉ thêm job có điểm phù hợp > 0.3 (30%)
                    if (matchScore > 0.3)
                    {
                        var recommendation = new JobRecommendationDto
                        {
                            IdJobPost = job.IdJobPost,
                            Title = job.Title,
                            Description = job.Description,
                            Requirements = job.Requirements,
                            Salary = job.Salary,
                            Location = job.Location,
                            Latitude = job.Latitude,
                            Longitude = job.Longitude,
                            WorkType = job.WorkType,
                            ExperienceLevel = job.ExperienceLevel,
                            IdCompany = job.IdCompany,
                            ApplicationDeadline = job.ApplicationDeadline,
                            Benefits = job.Benefits,
                            CreatedAt = job.CreatedAt,
                            UpdatedAt = job.UpdatedAt,
                            IsFeatured = job.IsFeatured,
                            PostStatus = job.PostStatus,
                            Company = job.Company != null ? new CompanyDto
                            {
                                IdCompany = job.Company.IdCompany,
                                CompanyName = job.Company.CompanyName,
                                LogoCompany = job.Company.LogoCompany,
                                Industry = job.Company.Industry,
                                Address = job.Company.Address
                            } : null,
                            MatchScore = matchScore,
                            MatchReason = GenerateMatchReason(job, candidate, user, matchScore),
                            MatchedSkills = GetMatchedSkills(job, candidate),
                            DistanceKm = await CalculateDistanceAsync(user.Address, job.Location)
                        };

                        recommendations.Add(recommendation);
                    }
                }

                // Sắp xếp theo điểm phù hợp và featured
                return recommendations
                    .OrderByDescending(r => r.IsFeatured)
                    .ThenByDescending(r => r.MatchScore)
                    .Take(request.Limit)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting personalized recommendations for user {UserId}", request.UserId);
                return new List<JobRecommendationDto>();
            }
        }

        public async Task<PersonalizedHomepageDto> GetPersonalizedHomepageDataAsync(string userId)
        {
            try
            {
                var request = new JobRecommendationRequestDto
                {
                    UserId = userId,
                    Limit = 6
                };

                var recommendedJobs = await GetPersonalizedRecommendationsAsync(request);
                
                // Lấy featured jobs (không trùng với recommended)
                var recommendedJobIds = recommendedJobs.Select(r => r.IdJobPost).ToHashSet();
                var featuredJobs = await _context.JobPostings
                    .Where(jp => jp.IsFeatured == 1 && 
                                !recommendedJobIds.Contains(jp.IdJobPost) &&
                                jp.PostStatus == "open" &&
                                (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow))
                    .Include(jp => jp.Company)
                    .OrderByDescending(jp => jp.CreatedAt)
                    .Take(6)
                    .Select(jp => new JobPostingDto
                    {
                        IdJobPost = jp.IdJobPost,
                        Title = jp.Title,
                        Description = jp.Description,
                        Requirements = jp.Requirements,
                        Salary = jp.Salary,
                        Location = jp.Location,
                        Latitude = jp.Latitude,
                        Longitude = jp.Longitude,
                        WorkType = jp.WorkType,
                        ExperienceLevel = jp.ExperienceLevel,
                        IdCompany = jp.IdCompany,
                        ApplicationDeadline = jp.ApplicationDeadline,
                        Benefits = jp.Benefits,
                        CreatedAt = jp.CreatedAt,
                        UpdatedAt = jp.UpdatedAt,
                        IsFeatured = jp.IsFeatured,
                        PostStatus = jp.PostStatus,
                        Company = jp.Company != null ? new CompanyDto
                        {
                            IdCompany = jp.Company.IdCompany,
                            CompanyName = jp.Company.CompanyName,
                            LogoCompany = jp.Company.LogoCompany,
                            Industry = jp.Company.Industry,
                            Address = jp.Company.Address
                        } : null
                    })
                    .ToListAsync();

                // Lấy featured companies
                var featuredCompanies = await _context.Companies
                    .Where(c => !string.IsNullOrEmpty(c.LogoCompany))
                    .OrderByDescending(c => c.CreatedAt)
                    .Take(6)
                    .Select(c => new CompanyDto
                    {
                        IdCompany = c.IdCompany,
                        CompanyName = c.CompanyName,
                        LogoCompany = c.LogoCompany,
                        Industry = c.Industry,
                        Address = c.Address
                    })
                    .ToListAsync();

                // Lấy user preferences
                var user = await _context.Users.FindAsync(userId);
                var candidate = await _context.CandidateInfo
                    .FirstOrDefaultAsync(c => c.IdUser == userId);

                var userPreferences = new UserPreferenceDto
                {
                    PreferredLocation = user?.Address,
                    Skills = candidate?.Skills?.Split(',', StringSplitOptions.RemoveEmptyEntries)
                        .Select(s => s.Trim()).ToList() ?? new List<string>(),
                    WorkPosition = candidate?.WorkPosition,
                    ExperienceYears = candidate?.ExperienceYears,
                    PreferredWorkType = null // Có thể thêm logic để xác định từ lịch sử
                };

                return new PersonalizedHomepageDto
                {
                    RecommendedJobs = recommendedJobs,
                    FeaturedJobs = featuredJobs,
                    FeaturedCompanies = featuredCompanies,
                    UserPreferences = userPreferences,
                    TrendingSkills = await GetTrendingSkillsAsync(8),
                    PopularLocations = await GetPopularLocationsAsync(8)
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting personalized homepage data for user {UserId}", userId);
                return new PersonalizedHomepageDto();
            }
        }

        public async Task<List<string>> GetTrendingSkillsAsync(int limit = 10)
        {
            try
            {
                // Lấy skills phổ biến từ job requirements và candidate skills
                var jobSkills = await _context.JobPostings
                    .Where(jp => jp.PostStatus == "open" && !string.IsNullOrEmpty(jp.Requirements))
                    .Select(jp => jp.Requirements)
                    .ToListAsync();

                var candidateSkills = await _context.CandidateInfo
                    .Where(c => !string.IsNullOrEmpty(c.Skills))
                    .Select(c => c.Skills)
                    .ToListAsync();

                var allSkills = new List<string>();
                allSkills.AddRange(jobSkills.Where(s => !string.IsNullOrEmpty(s)));
                allSkills.AddRange(candidateSkills.Where(s => !string.IsNullOrEmpty(s)));

                // Extract skills từ text (simple approach)
                var skillCounts = new Dictionary<string, int>();
                foreach (var skillText in allSkills)
                {
                    var skills = ExtractSkillsFromText(skillText);
                    foreach (var skill in skills)
                    {
                        if (skillCounts.ContainsKey(skill))
                            skillCounts[skill]++;
                        else
                            skillCounts[skill] = 1;
                    }
                }

                return skillCounts
                    .OrderByDescending(kvp => kvp.Value)
                    .Take(limit)
                    .Select(kvp => kvp.Key)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting trending skills");
                return new List<string>();
            }
        }

        public async Task<List<string>> GetPopularLocationsAsync(int limit = 10)
        {
            try
            {
                var locations = await _context.JobPostings
                    .Where(jp => jp.PostStatus == "open" && !string.IsNullOrEmpty(jp.Location))
                    .GroupBy(jp => jp.Location)
                    .Select(g => new { Location = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .Take(limit)
                    .Select(x => x.Location)
                    .ToListAsync();

                return locations;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting popular locations");
                return new List<string>();
            }
        }

        public async Task<double> CalculateJobMatchScoreAsync(string userId, string jobId)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                var candidate = await _context.CandidateInfo
                    .FirstOrDefaultAsync(c => c.IdUser == userId);
                var job = await _context.JobPostings
                    .Include(jp => jp.Company)
                    .FirstOrDefaultAsync(jp => jp.IdJobPost == jobId);

                if (user == null || job == null)
                    return 0.0;

                double score = 0.0;
                double maxScore = 0.0;

                // 1. Skills matching (40% weight)
                maxScore += 40;
                if (candidate != null && !string.IsNullOrEmpty(candidate.Skills) && !string.IsNullOrEmpty(job.Requirements))
                {
                    var userSkills = ExtractSkillsFromText(candidate.Skills);
                    var jobSkills = ExtractSkillsFromText(job.Requirements);
                    var matchedSkills = userSkills.Intersect(jobSkills, StringComparer.OrdinalIgnoreCase).Count();
                    var totalJobSkills = jobSkills.Count;
                    
                    if (totalJobSkills > 0)
                    {
                        score += (double)matchedSkills / totalJobSkills * 40;
                    }
                }

                // 2. Location matching (25% weight)
                maxScore += 25;
                if (!string.IsNullOrEmpty(user.Address) && !string.IsNullOrEmpty(job.Location))
                {
                    var distance = await CalculateDistanceAsync(user.Address, job.Location);
                    if (distance.HasValue && distance.Value <= 50) // Within 50km
                    {
                        score += (50 - distance.Value) / 50 * 25;
                    }
                }

                // 3. Experience level matching (20% weight)
                maxScore += 20;
                if (candidate?.ExperienceYears.HasValue == true && !string.IsNullOrEmpty(job.ExperienceLevel))
                {
                    var experienceMatch = CalculateExperienceMatch(candidate.ExperienceYears.Value, job.ExperienceLevel);
                    score += experienceMatch * 20;
                }

                // 4. Work type preference (10% weight)
                maxScore += 10;
                // Có thể thêm logic để xác định work type preference từ lịch sử
                score += 5; // Default score

                // 5. Salary expectation (5% weight)
                maxScore += 5;
                // Có thể thêm logic để so sánh salary expectation
                score += 2.5; // Default score

                return maxScore > 0 ? Math.Min(score / maxScore, 1.0) : 0.0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating job match score for user {UserId} and job {JobId}", userId, jobId);
                return 0.0;
            }
        }

        private List<string> ExtractSkillsFromText(string text)
        {
            if (string.IsNullOrEmpty(text))
                return new List<string>();

            // Common programming languages and technologies
            var commonSkills = new[]
            {
                "C#", "Java", "Python", "JavaScript", "TypeScript", "React", "Angular", "Vue", "Node.js",
                "ASP.NET", "Spring", "Django", "Flask", "Express", "SQL", "MySQL", "PostgreSQL", "MongoDB",
                "Redis", "Docker", "Kubernetes", "AWS", "Azure", "Git", "GitHub", "GitLab", "Jenkins",
                "HTML", "CSS", "Bootstrap", "Tailwind", "SASS", "LESS", "Webpack", "Vite", "NPM", "Yarn",
                "PHP", "Laravel", "Symfony", "Ruby", "Rails", "Go", "Rust", "Swift", "Kotlin", "Flutter",
                "React Native", "Xamarin", "Unity", "Unreal", "Photoshop", "Illustrator", "Figma", "Sketch",
                "Linux", "Windows", "macOS", "iOS", "Android", "REST", "GraphQL", "Microservices", "API",
                "Machine Learning", "AI", "Data Science", "Analytics", "Business Intelligence", "DevOps",
                "Agile", "Scrum", "Kanban", "JIRA", "Confluence", "Slack", "Teams", "Zoom"
            };

            var foundSkills = new List<string>();
            var textLower = text.ToLower();

            foreach (var skill in commonSkills)
            {
                if (textLower.Contains(skill.ToLower()))
                {
                    foundSkills.Add(skill);
                }
            }

            // Also extract skills from comma-separated lists
            var commaSkills = text.Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(s => s.Trim())
                .Where(s => s.Length > 2 && s.Length < 50)
                .ToList();

            foundSkills.AddRange(commaSkills);

            return foundSkills.Distinct().ToList();
        }

        private double CalculateExperienceMatch(int userExperience, string jobExperienceLevel)
        {
            var level = jobExperienceLevel.ToLower();
            
            if (level.Contains("intern") || level.Contains("fresher") || level.Contains("entry"))
                return userExperience <= 1 ? 1.0 : Math.Max(0.3, 1.0 - (userExperience - 1) * 0.2);
            
            if (level.Contains("junior") || level.Contains("1-2") || level.Contains("2-3"))
                return userExperience >= 1 && userExperience <= 3 ? 1.0 : Math.Max(0.2, 1.0 - Math.Abs(userExperience - 2) * 0.3);
            
            if (level.Contains("middle") || level.Contains("mid") || level.Contains("3-5") || level.Contains("4-6"))
                return userExperience >= 3 && userExperience <= 6 ? 1.0 : Math.Max(0.2, 1.0 - Math.Abs(userExperience - 4.5) * 0.2);
            
            if (level.Contains("senior") || level.Contains("lead") || level.Contains("5+") || level.Contains("6+"))
                return userExperience >= 5 ? 1.0 : Math.Max(0.1, userExperience / 5.0);
            
            return 0.5; // Default match
        }

        private string GenerateMatchReason(Models.JobPosting job, Models.CandidateInfo? candidate, Models.User user, double matchScore)
        {
            var reasons = new List<string>();

            if (candidate != null && !string.IsNullOrEmpty(candidate.Skills) && !string.IsNullOrEmpty(job.Requirements))
            {
                var userSkills = ExtractSkillsFromText(candidate.Skills);
                var jobSkills = ExtractSkillsFromText(job.Requirements);
                var matchedSkills = userSkills.Intersect(jobSkills, StringComparer.OrdinalIgnoreCase).ToList();
                
                if (matchedSkills.Any())
                {
                    reasons.Add($"Kỹ năng phù hợp: {string.Join(", ", matchedSkills.Take(3))}");
                }
            }

            if (!string.IsNullOrEmpty(user.Address) && !string.IsNullOrEmpty(job.Location))
            {
                var distance = CalculateDistanceAsync(user.Address, job.Location).Result;
                if (distance.HasValue && distance.Value <= 20)
                {
                    reasons.Add($"Gần khu vực của bạn ({distance.Value:F1}km)");
                }
            }

            if (candidate?.ExperienceYears.HasValue == true && !string.IsNullOrEmpty(job.ExperienceLevel))
            {
                var experienceMatch = CalculateExperienceMatch(candidate.ExperienceYears.Value, job.ExperienceLevel);
                if (experienceMatch > 0.7)
                {
                    reasons.Add("Kinh nghiệm phù hợp");
                }
            }

            if (reasons.Any())
            {
                return string.Join(" • ", reasons);
            }

            return matchScore > 0.7 ? "Công việc phù hợp với hồ sơ của bạn" : "Có thể phù hợp với bạn";
        }

        private List<string> GetMatchedSkills(Models.JobPosting job, Models.CandidateInfo? candidate)
        {
            if (candidate == null || string.IsNullOrEmpty(candidate.Skills) || string.IsNullOrEmpty(job.Requirements))
                return new List<string>();

            var userSkills = ExtractSkillsFromText(candidate.Skills);
            var jobSkills = ExtractSkillsFromText(job.Requirements);
            
            return userSkills.Intersect(jobSkills, StringComparer.OrdinalIgnoreCase).ToList();
        }

        private async Task<double?> CalculateDistanceAsync(string? userAddress, string? jobLocation)
        {
            if (string.IsNullOrEmpty(userAddress) || string.IsNullOrEmpty(jobLocation))
                return null;

            try
            {
                // Simple distance calculation based on city names
                // In a real implementation, you would use proper geocoding
                var userCity = ExtractCityFromAddress(userAddress);
                var jobCity = ExtractCityFromAddress(jobLocation);

                if (string.IsNullOrEmpty(userCity) || string.IsNullOrEmpty(jobCity))
                    return null;

                // If same city, return 0
                if (userCity.Equals(jobCity, StringComparison.OrdinalIgnoreCase))
                    return 0;

                // Simple distance mapping for major cities in Vietnam
                var cityDistances = new Dictionary<string, Dictionary<string, double>>
                {
                    ["hà nội"] = new Dictionary<string, double>
                    {
                        ["hồ chí minh"] = 1130,
                        ["đà nẵng"] = 760,
                        ["hải phòng"] = 120,
                        ["cần thơ"] = 1200
                    },
                    ["hồ chí minh"] = new Dictionary<string, double>
                    {
                        ["hà nội"] = 1130,
                        ["đà nẵng"] = 650,
                        ["hải phòng"] = 1200,
                        ["cần thơ"] = 170
                    },
                    ["đà nẵng"] = new Dictionary<string, double>
                    {
                        ["hà nội"] = 760,
                        ["hồ chí minh"] = 650,
                        ["hải phòng"] = 800,
                        ["cần thơ"] = 700
                    }
                };

                var userCityLower = userCity.ToLower();
                var jobCityLower = jobCity.ToLower();

                if (cityDistances.ContainsKey(userCityLower) && 
                    cityDistances[userCityLower].ContainsKey(jobCityLower))
                {
                    return cityDistances[userCityLower][jobCityLower];
                }

                // Default distance for unknown cities
                return 50;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating distance between {UserAddress} and {JobLocation}", userAddress, jobLocation);
                return null;
            }
        }

        private string ExtractCityFromAddress(string address)
        {
            if (string.IsNullOrEmpty(address))
                return string.Empty;

            var majorCities = new[]
            {
                "Hà Nội", "Hồ Chí Minh", "Đà Nẵng", "Hải Phòng", "Cần Thơ", "Nha Trang", "Huế", "Vũng Tàu",
                "Quy Nhon", "Thái Nguyên", "Nam Định", "Vinh", "Buôn Ma Thuột", "Hạ Long", "Long Xuyên",
                "Thủ Dầu Một", "Biên Hòa", "Rạch Giá", "Mỹ Tho", "Cao Lãnh", "Sóc Trăng", "Bạc Liêu",
                "Cà Mau", "Kiên Giang", "An Giang", "Đồng Tháp", "Vĩnh Long", "Trà Vinh", "Bến Tre"
            };

            foreach (var city in majorCities)
            {
                if (address.Contains(city, StringComparison.OrdinalIgnoreCase))
                {
                    return city;
                }
            }

            // If no major city found, try to extract from common patterns
            var patterns = new[]
            {
                @"Thành phố\s+([^,\n]+)",
                @"Tỉnh\s+([^,\n]+)",
                @"([^,\n]+)\s*,\s*Việt Nam"
            };

            foreach (var pattern in patterns)
            {
                var match = Regex.Match(address, pattern, RegexOptions.IgnoreCase);
                if (match.Success)
                {
                    return match.Groups[1].Value.Trim();
                }
            }

            return string.Empty;
        }
    }
}
