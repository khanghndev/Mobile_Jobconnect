using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.Services;
using Microsoft.Extensions.Logging;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JobPostingController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly IGeocodingService _geocodingService;
        private readonly ISpatialQueryService _spatialQueryService;
        private readonly ILogger<JobPostingController> _logger;

        public JobPostingController(
            JobConnectDbContext context,
            IGeocodingService geocodingService,
            ISpatialQueryService spatialQueryService,
            ILogger<JobPostingController> logger)
        {
            _context = context;
            _geocodingService = geocodingService;
            _spatialQueryService = spatialQueryService;
            _logger = logger;
        }

        private string? GetCurrentUserId()
            => User.FindFirst(ClaimTypes.NameIdentifier)?.Value
               ?? User.FindFirst("sub")?.Value;

        // ---------------------------------------------------------------------
        // GET: api/jobposting  (còn hạn, open|waiting)
        // ---------------------------------------------------------------------
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> GetAll()
        {
            var jobPostings = await _context.JobPostings
                .Where(jp => (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow))
                .Where(jp => jp.PostStatus == "open" || jp.PostStatus == "waiting")
                .Include(jp => jp.Company)
                .OrderByDescending(jp => jp.IsFeatured)
                .ThenByDescending(jp => jp.CreatedAt)
                .ToListAsync();

            return Ok(jobPostings);
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/all (quản trị)
        // ---------------------------------------------------------------------
        [HttpGet("all")]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> GetAllIncludingExpired()
        {
            var jobPostings = await _context.JobPostings
                .Include(jp => jp.Company)
                .OrderByDescending(jp => jp.CreatedAt)
                .ToListAsync();

            return Ok(jobPostings);
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/featured
        // ---------------------------------------------------------------------
        [HttpGet("featured")]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> GetAllFeatured()
        {
            var jobPostings = await _context.JobPostings
                .Where(jp => jp.IsFeatured == 1 &&
                             (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow))
                .Where(jp => jp.PostStatus == "open" || jp.PostStatus == "waiting")
                .Include(jp => jp.Company)
                .OrderByDescending(jp => jp.CreatedAt)
                .ToListAsync();

            return Ok(jobPostings);
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/company/{companyId}
        // ---------------------------------------------------------------------
        [HttpGet("company/{companyId}")]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> GetByCompany(string companyId)
        {
            var list = await _context.JobPostings
                .Where(jp => jp.IdCompany == companyId)
                .Include(jp => jp.Company)
                .OrderByDescending(jp => jp.CreatedAt)
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
                .ToListAsync();

            return Ok(list);
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/search?locationQuery=...
        // ---------------------------------------------------------------------
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> SearchJobs([FromQuery] string? locationQuery)
        {
            var query = _context.JobPostings
                .Where(jp => jp.PostStatus == "open" || jp.PostStatus == "waiting")
                .Include(jp => jp.Company)
                .AsQueryable();

            if (string.IsNullOrWhiteSpace(locationQuery))
                return BadRequest(new { message = "locationQuery là bắt buộc." });

            var term = locationQuery.Trim().ToLower();
            query = query.Where(jp =>
                jp.Location != null &&
                jp.Location.ToLower().Contains(term) &&
                (jp.ApplicationDeadline == null || jp.ApplicationDeadline >= DateTime.UtcNow)  // <-- thêm ngoặc
            );

            var results = await query
                .OrderByDescending(jp => jp.IsFeatured)
                .ThenByDescending(jp => jp.CreatedAt)
                .ToListAsync();

            _logger.LogInformation("Found {Count} jobs for locationQuery: '{LocationQuery}'", results.Count, locationQuery);
            return Ok(results);
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/{id}
        // ---------------------------------------------------------------------
        [HttpGet("{id}")]
        public async Task<ActionResult<JobPostingDto>> GetById(string id)
        {
            var jobPosting = await _context.JobPostings
                .Include(jp => jp.Company)
                .FirstOrDefaultAsync(jp => jp.IdJobPost == id);

            if (jobPosting == null)
                return NotFound(new { message = "Không tìm thấy tin tuyển dụng." });

            return Ok(jobPosting);
        }

        // ---------------------------------------------------------------------
        // POST: api/jobposting  (API tự kiểm tra & trừ quota)
        // ---------------------------------------------------------------------
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateJobPostingDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // 0) Phải có user
            var recruiterId = GetCurrentUserId();
            if (string.IsNullOrEmpty(recruiterId))
                return Unauthorized(new { message = "Bạn cần đăng nhập để đăng tin." });

            // 1) Công ty phải tồn tại
            var companyExists = await _context.Companies.AnyAsync(c => c.IdCompany == dto.IdCompany);
            if (!companyExists)
                return BadRequest(new { message = $"Công ty '{dto.IdCompany}' không tồn tại." });

            // Dùng transaction để đảm bảo nhất quán
            await using var tx = await _context.Database.BeginTransactionAsync();

            // 2) Lấy transaction còn hiệu lực & còn lượt
            var activeTx = await _context.JobTransactions
                .Where(t => t.IdUser == recruiterId &&
                            t.Status == "Completed" &&
                            t.ExpiryDate >= DateTime.UtcNow &&
                            t.RemainingJobPosts > 0)
                .OrderByDescending(t => t.ExpiryDate)
                .FirstOrDefaultAsync();

            if (activeTx == null)
                return BadRequest(new { message = "Bạn không có quota đăng tin hợp lệ." });

            // 3) Geocode nếu thiếu tọa độ
            decimal? lat = dto.Latitude, lon = dto.Longitude;
            if ((!lat.HasValue || !lon.HasValue) && !string.IsNullOrWhiteSpace(dto.Location))
            {
                var coords = await _geocodingService.GetCoordinatesAsync(dto.Location);
                if (coords != null) { lat = coords.Latitude; lon = coords.Longitude; }
            }

            // 4) Tạo job
            var now = DateTime.UtcNow;
            var newJob = new JobPosting
            {
                IdJobPost = Guid.NewGuid().ToString(),
                Title = dto.Title,
                Description = dto.Description,
                Requirements = dto.Requirements,
                Salary = dto.Salary,
                Location = dto.Location,
                Latitude = lat,
                Longitude = lon,
                WorkType = dto.WorkType,
                ExperienceLevel = dto.ExperienceLevel,
                IdCompany = dto.IdCompany,
                ApplicationDeadline = dto.ApplicationDeadline,
                Benefits = dto.Benefits,
                CreatedAt = now,
                UpdatedAt = now,
                PostStatus = "waiting",
                IsFeatured = 0
            };

            // 5) Trừ quota & ghi log
            activeTx.RemainingJobPosts -= 1;
            if (activeTx.RemainingJobPosts < 0)
                return Conflict(new { message = "Quota đã hết, vui lòng mua gói mới." });

            _context.JobTransactions.Update(activeTx);

            _context.JobPostUsageLogs.Add(new JobPostUsageLog
            {
                IdLog = Guid.NewGuid().ToString(),
                IdTransaction = activeTx.IdTransaction,
                IdJobPost = newJob.IdJobPost,
                UsedAt = now
            });

            // 6) Lưu
            _context.JobPostings.Add(newJob);
            await _context.SaveChangesAsync();
            await tx.CommitAsync();

            // 7) Include company để trả về đầy đủ
            newJob.Company = await _context.Companies.FindAsync(newJob.IdCompany);

            return CreatedAtAction(nameof(GetById), new { id = newJob.IdJobPost }, newJob);
        }

        // ---------------------------------------------------------------------
        // PUT: api/jobposting/{id}
        // ---------------------------------------------------------------------
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateJobPostingDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var entity = await _context.JobPostings.FindAsync(id);
            if (entity == null) return NotFound(new { message = "Không tìm thấy tin tuyển dụng." });

            bool locationOrCoordsChanged = false;

            if (!string.IsNullOrEmpty(dto.Title)) entity.Title = dto.Title;
            if (!string.IsNullOrEmpty(dto.Description)) entity.Description = dto.Description;
            if (!string.IsNullOrEmpty(dto.Requirements)) entity.Requirements = dto.Requirements;
            entity.Salary = dto.Salary;

            if (!string.IsNullOrEmpty(dto.Location) && entity.Location != dto.Location)
            {
                entity.Location = dto.Location;
                locationOrCoordsChanged = true;
            }

            if (dto.Latitude.HasValue) { locationOrCoordsChanged |= entity.Latitude != dto.Latitude; entity.Latitude = dto.Latitude; }
            if (dto.Longitude.HasValue) { locationOrCoordsChanged |= entity.Longitude != dto.Longitude; entity.Longitude = dto.Longitude; }

            if (locationOrCoordsChanged && (!dto.Latitude.HasValue || !dto.Longitude.HasValue) && !string.IsNullOrWhiteSpace(entity.Location))
            {
                _logger.LogInformation("Re-geocoding job {JobId} for new address: {Location}", id, entity.Location);
                var coords = await _geocodingService.GetCoordinatesAsync(entity.Location);
                if (coords != null) { entity.Latitude = coords.Latitude; entity.Longitude = coords.Longitude; }
                else { entity.Latitude = null; entity.Longitude = null; }
            }

            if (!string.IsNullOrEmpty(dto.WorkType)) entity.WorkType = dto.WorkType;
            if (!string.IsNullOrEmpty(dto.ExperienceLevel)) entity.ExperienceLevel = dto.ExperienceLevel;
            entity.ApplicationDeadline = dto.ApplicationDeadline;
            entity.Benefits = string.IsNullOrEmpty(dto.Benefits) ? null : dto.Benefits;

            bool postStatusChangedToInvalid = false;
            if (!string.IsNullOrEmpty(dto.PostStatus))
            {
                if ((dto.PostStatus == "closed" || dto.PostStatus == "editing") && entity.PostStatus != dto.PostStatus)
                    postStatusChangedToInvalid = true;

                entity.PostStatus = dto.PostStatus;
            }

            entity.UpdatedAt = DateTime.UtcNow;

            if (postStatusChangedToInvalid && (entity.PostStatus == "closed" || entity.PostStatus == "editing"))
            {
                var savedJobsToRemove = await _context.JobSaveds.Where(js => js.IdJobPost == id).ToListAsync();
                if (savedJobsToRemove.Any())
                {
                    _context.JobSaveds.RemoveRange(savedJobsToRemove);
                    _logger.LogInformation("Removed {Count} JobSaved for JobPosting {Id} due to status '{Status}'",
                        savedJobsToRemove.Count, id, entity.PostStatus);
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // ---------------------------------------------------------------------
        // DELETE: api/jobposting/{id}
        // ---------------------------------------------------------------------
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var jobPosting = await _context.JobPostings.FindAsync(id);
            if (jobPosting == null) return NotFound(new { message = "Không tìm thấy tin tuyển dụng." });

            _context.JobPostings.Remove(jobPosting);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // ---------------------------------------------------------------------
        // PATCH: api/jobposting/{id}/status
        // ---------------------------------------------------------------------
        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] UpdateStatusDto dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Status))
                return BadRequest(new { message = "Trường 'status' là bắt buộc." });

            var valid = new[] { "open", "closed", "waiting", "editing" };
            if (!valid.Contains(dto.Status.ToLower()))
                return BadRequest(new { message = $"Giá trị status không hợp lệ. Chỉ chấp nhận: {string.Join(", ", valid)}" });

            var job = await _context.JobPostings.FindAsync(id);
            if (job == null) return NotFound(new { message = "Không tìm thấy tin tuyển dụng." });

            job.PostStatus = dto.Status;
            job.UpdatedAt = DateTime.UtcNow;

            _context.Entry(job).Property(j => j.PostStatus).IsModified = true;
            _context.Entry(job).Property(j => j.UpdatedAt).IsModified = true;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // ---------------------------------------------------------------------
        // GET: api/jobposting/nearby
        // ---------------------------------------------------------------------
        [HttpGet("nearby")]
        public async Task<ActionResult<IEnumerable<JobPostingWithDistanceDto>>> GetNearbyJobs([FromQuery] NearbyJobsRequestDto request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var nearbyJobs = await _spatialQueryService.GetNearbyJobsAsync(request);
                return Ok(nearbyJobs);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching nearby jobs: lat={Lat}, lon={Lon}, r={R}",
                    request.Latitude, request.Longitude, request.RadiusKm);
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm công việc gần đây." });
            }
        }

        // POST: api/jobposting/area
        [HttpPost("area")]
        [Consumes("application/json")]
        public async Task<ActionResult<IEnumerable<JobPostingDto>>> GetJobsInArea(
            [FromBody] AreaJobsRequestDto request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (request.Polygon == null || request.Polygon.Count < 3)
                return BadRequest(new { message = "Polygon phải có ít nhất 3 điểm." });

            try
            {
                var jobsInArea = await _spatialQueryService.GetJobsInAreaAsync(request);
                return Ok(jobsInArea);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching jobs in area (points={Cnt})",
                    request.Polygon?.Count ?? 0);
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm công việc trong vùng." });
            }
        }
        // POST: api/jobposting/nearby
        [HttpPost("nearby")]
        [Consumes("application/json")]
        public async Task<ActionResult<IEnumerable<JobPostingWithDistanceDto>>> PostNearby(
            [FromBody] NearbyJobsRequestDto request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                var nearbyJobs = await _spatialQueryService.GetNearbyJobsAsync(request);
                return Ok(nearbyJobs);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching nearby jobs: lat={Lat}, lon={Lon}, r={R}",
                    request.Latitude, request.Longitude, request.RadiusKm);
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm công việc gần đây." });
            }
        }

    }
}
