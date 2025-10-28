using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Services
{
    public class SpatialQueryService : ISpatialQueryService
    {
        private readonly JobConnectDbContext _context;
        private readonly ILogger<SpatialQueryService> _logger;

        public SpatialQueryService(JobConnectDbContext context, ILogger<SpatialQueryService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<JobPostingWithDistanceDto>> GetNearbyJobsAsync(NearbyJobsRequestDto request)
        {
            try
            {
                // Get jobs with coordinates within the specified radius
                var jobs = await _context.JobPostings
                    .Where(jp => jp.PostStatus == "open" && 
                                (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow) &&
                                jp.Latitude.HasValue && jp.Longitude.HasValue)
                    .Include(jp => jp.Company)
                    .ToListAsync();

                // Calculate distance and filter by radius
                var nearbyJobs = jobs
                    .Where(jp => CalculateDistance(request.Latitude, request.Longitude, 
                                                  jp.Latitude.Value, jp.Longitude.Value) <= request.RadiusKm)
                    .Select(jp => new JobPostingWithDistanceDto
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
                        DistanceKm = CalculateDistance(request.Latitude, request.Longitude, 
                                                      jp.Latitude.Value, jp.Longitude.Value),
                        Company = jp.Company == null ? null : new CompanyDto
                        {
                            IdCompany = jp.Company.IdCompany,
                            CompanyName = jp.Company.CompanyName,
                            LogoCompany = jp.Company.LogoCompany
                        }
                    })
                    .OrderBy(jp => jp.DistanceKm)
                    .ThenByDescending(jp => jp.IsFeatured)
                    .ThenByDescending(jp => jp.CreatedAt)
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();

                _logger.LogInformation("Found {Count} nearby jobs within {Radius}km of lat: {Latitude}, lon: {Longitude}", 
                    nearbyJobs.Count, request.RadiusKm, request.Latitude, request.Longitude);

                return nearbyJobs;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching nearby jobs for lat: {Latitude}, lon: {Longitude}, radius: {Radius}", 
                    request.Latitude, request.Longitude, request.RadiusKm);
                throw;
            }
        }

        public async Task<IEnumerable<JobPostingDto>> GetJobsInAreaAsync(AreaJobsRequestDto request)
        {
            try
            {
                // Get jobs with coordinates
                var jobs = await _context.JobPostings
                    .Where(jp => jp.PostStatus == "open" && 
                                (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow) &&
                                jp.Latitude.HasValue && jp.Longitude.HasValue)
                    .Include(jp => jp.Company)
                    .ToListAsync();

                // Filter jobs that are inside the polygon
                var jobsInArea = jobs
                    .Where(jp => IsPointInPolygon(jp.Latitude.Value, jp.Longitude.Value, request.Polygon))
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
                        Company = jp.Company == null ? null : new CompanyDto
                        {
                            IdCompany = jp.Company.IdCompany,
                            CompanyName = jp.Company.CompanyName,
                            LogoCompany = jp.Company.LogoCompany
                        }
                    })
                    .OrderByDescending(jp => jp.IsFeatured)
                    .ThenByDescending(jp => jp.CreatedAt)
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();

                _logger.LogInformation("Found {Count} jobs in area with {PointCount} polygon points", 
                    jobsInArea.Count, request.Polygon.Count);

                return jobsInArea;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching jobs in area with {PointCount} polygon points", request.Polygon.Count);
                throw;
            }
        }

        public decimal CalculateDistance(decimal lat1, decimal lon1, decimal lat2, decimal lon2)
        {
            const double R = 6371; // Earth's radius in kilometers
            var dLat = ToRadians(lat2 - lat1);
            var dLon = ToRadians(lon2 - lon1);
            var a = Math.Sin((double)dLat / 2) * Math.Sin((double)dLat / 2) +
                    Math.Cos((double)ToRadians(lat1)) * Math.Cos((double)ToRadians(lat2)) *
                    Math.Sin((double)dLon / 2) * Math.Sin((double)dLon / 2);
            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return (decimal)(R * c);
        }

        private decimal ToRadians(decimal degrees)
        {
            return degrees * (decimal)(Math.PI / 180);
        }

        public bool IsPointInPolygon(decimal pointLat, decimal pointLon, List<PointDto> polygon)
        {
            bool inside = false;
            int j = polygon.Count - 1;

            for (int i = 0; i < polygon.Count; i++)
            {
                if (((polygon[i].Latitude > pointLat) != (polygon[j].Latitude > pointLat)) &&
                    (pointLon < (polygon[j].Longitude - polygon[i].Longitude) * (pointLat - polygon[i].Latitude) / 
                     (polygon[j].Latitude - polygon[i].Latitude) + polygon[i].Longitude))
                {
                    inside = !inside;
                }
                j = i;
            }

            return inside;
        }
    }
}
