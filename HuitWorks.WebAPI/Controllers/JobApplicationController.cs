using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JobApplicationController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public JobApplicationController(JobConnectDbContext context) => _context = context;

        // GET all
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobApplicationDto>>> GetAll()
        {
            var list = await _context.JobApplications
                .Select(ja => new JobApplicationDto
                {
                    IdJobPost = ja.IdJobPost,
                    IdUser = ja.IdUser,
                    CvFileUrl = ja.CvFileUrl,
                    CoverLetter = ja.CoverLetter,
                    ApplicationStatus = ja.ApplicationStatus,
                    SubmittedAt = ja.SubmittedAt,
                    UpdatedAt = ja.UpdatedAt
                }).ToListAsync();

            return Ok(list);
        }

        // GET by user
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<JobApplicationDto>>> GetByUser(string idUser)
        {
            var jobApplications = await _context.JobApplications
           .Include(ja => ja.JobPosting) // Nạp thông tin JobPosting liên quan
           .ThenInclude(jp => jp.Company)
           .Where(ja => ja.IdUser == idUser)
           .Select(ja => new JobApplicationDto
           {
               IdJobPost = ja.IdJobPost,
               IdUser = ja.IdUser,
               CvFileUrl = ja.CvFileUrl,
               CoverLetter = ja.CoverLetter,
               ApplicationStatus = ja.ApplicationStatus,
               SubmittedAt = ja.SubmittedAt,
               UpdatedAt = ja.UpdatedAt,
               JobPosting = ja.JobPosting != null ? new JobPosting
               {
                   IdJobPost = ja.JobPosting.IdJobPost,
                   Title = ja.JobPosting.Title,
                   Description = ja.JobPosting.Description,
                   Requirements = ja.JobPosting.Requirements,
                   Salary = ja.JobPosting.Salary,
                   Location = ja.JobPosting.Location,
                   WorkType = ja.JobPosting.WorkType,
                   ExperienceLevel = ja.JobPosting.ExperienceLevel,
                   IdCompany = ja.JobPosting.IdCompany,
                   ApplicationDeadline = ja.JobPosting.ApplicationDeadline,
                   Benefits = ja.JobPosting.Benefits,
                   CreatedAt = ja.JobPosting.CreatedAt,
                   UpdatedAt = ja.JobPosting.UpdatedAt,
                   PostStatus = ja.JobPosting.PostStatus,
                   IsFeatured = ja.JobPosting.IsFeatured,
                   Company = ja.JobPosting.Company != null ? new Company
                   {
                       IdCompany = ja.JobPosting.Company.IdCompany,
                       CompanyName = ja.JobPosting.Company.CompanyName,
                       TaxCode = ja.JobPosting.Company.TaxCode,
                       Address = ja.JobPosting.Company.Address,
                       Description = ja.JobPosting.Company.Description,
                       LogoCompany = ja.JobPosting.Company.LogoCompany,
                       WebsiteUrl = ja.JobPosting.Company.WebsiteUrl,
                       Scale = ja.JobPosting.Company.Scale,
                       Industry = ja.JobPosting.Company.Industry,
                       BusinessLicenseUrl = ja.JobPosting.Company.BusinessLicenseUrl,
                       Status = ja.JobPosting.Company.Status,
                       IsFeatured = ja.JobPosting.Company.IsFeatured,
                       CreatedAt = ja.JobPosting.Company.CreatedAt,
                       UpdatedAt = ja.JobPosting.Company.UpdatedAt,
                   }
                   :
                  new Company
                  {
                      IdCompany = "",
                      CompanyName = "",
                      TaxCode = "",
                      Address = "",
                      Description = "",
                      LogoCompany = "",
                      WebsiteUrl = "",
                      Industry = "",
                      Scale = "",
                      BusinessLicenseUrl = "",
                      Status = "",
                      IsFeatured = 0,
                      CreatedAt = DateTime.Now,
                      UpdatedAt = DateTime.Now
                  }

               }
               :
               new JobPosting
               {
                   IdJobPost = "",
                   Title = "",
                   Description = "",
                   Requirements = "",
                   Salary = 0,
                   Location = "",
                   WorkType = "",
                   ExperienceLevel = "",
                   IdCompany = "",
                   ApplicationDeadline = DateTime.Now,
                   Benefits = "",
                   CreatedAt = DateTime.Now,
                   UpdatedAt = DateTime.Now,
                   PostStatus = "",
                   IsFeatured = 0,
                   Company = new Company
                   {
                       IdCompany = "",
                       CompanyName = "",
                       TaxCode = "",
                       Address = "",
                       Description = "",
                       LogoCompany = "",
                       WebsiteUrl = "",
                       Industry = "",
                       Scale = "",
                       BusinessLicenseUrl = "",
                       Status = "",
                       IsFeatured = 0,
                       CreatedAt = DateTime.Now,
                       UpdatedAt = DateTime.Now
                   }

               }
           })
           .ToListAsync();

            if (jobApplications == null || !jobApplications.Any()) // Sử dụng .Any() cho IEnumerable
            {
                return NotFound(new { message = "Không tìm thấy hồ sơ ứng tuyển cho user này." });
            }

            return Ok(jobApplications);
        }

        // GET by composite key
        [HttpGet("{jobPost}/{user}")]
        public async Task<ActionResult<JobApplicationDto>> GetByKey(string jobPost, string user)
        {
            var ja = await _context.JobApplications.FindAsync(jobPost, user);

            if (ja == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ ứng tuyển." });

            return Ok(new JobApplicationDto
            {
                IdJobPost = ja.IdJobPost,
                IdUser = ja.IdUser,
                CvFileUrl = ja.CvFileUrl,
                CoverLetter = ja.CoverLetter,
                ApplicationStatus = ja.ApplicationStatus,
                SubmittedAt = ja.SubmittedAt,
                UpdatedAt = ja.UpdatedAt,
                JobPosting = ja.JobPosting != null ? new JobPosting
                {
                    IdJobPost = ja.JobPosting.IdJobPost,
                    Title = ja.JobPosting.Title,
                    Description = ja.JobPosting.Description,
                    Requirements = ja.JobPosting.Requirements,
                    Salary = ja.JobPosting.Salary,
                    Location = ja.JobPosting.Location,
                    WorkType = ja.JobPosting.WorkType,
                    ExperienceLevel = ja.JobPosting.ExperienceLevel,
                    IdCompany = ja.JobPosting.IdCompany,
                    ApplicationDeadline = ja.JobPosting.ApplicationDeadline,
                    Benefits = ja.JobPosting.Benefits,
                    CreatedAt = ja.JobPosting.CreatedAt,
                    UpdatedAt = ja.JobPosting.UpdatedAt,
                    PostStatus = ja.JobPosting.PostStatus,
                    IsFeatured = ja.JobPosting.IsFeatured,
                    Company = ja.JobPosting.Company != null ? new Company
                    {
                        IdCompany = ja.JobPosting.Company.IdCompany,
                        CompanyName = ja.JobPosting.Company.CompanyName,
                        TaxCode = ja.JobPosting.Company.TaxCode,
                        Address = ja.JobPosting.Company.Address,
                        Description = ja.JobPosting.Company.Description,
                        LogoCompany = ja.JobPosting.Company.LogoCompany,
                        WebsiteUrl = ja.JobPosting.Company.WebsiteUrl,
                        Scale = ja.JobPosting.Company.Scale,
                        Industry = ja.JobPosting.Company.Industry,
                        BusinessLicenseUrl = ja.JobPosting.Company.BusinessLicenseUrl,
                        Status = ja.JobPosting.Company.Status,
                        IsFeatured = ja.JobPosting.Company.IsFeatured,
                        CreatedAt = ja.JobPosting.Company.CreatedAt,
                        UpdatedAt = ja.JobPosting.Company.UpdatedAt,
                    }
                   :
                   new Company
                   {
                       IdCompany = "",
                       CompanyName = "",
                       TaxCode = "",
                       Address = "",
                       Description = "",
                       LogoCompany = "",
                       WebsiteUrl = "",
                       Industry = "",
                       Scale = "",
                       BusinessLicenseUrl = "",
                       Status = "",
                       IsFeatured = 0,
                       CreatedAt = DateTime.Now,
                       UpdatedAt = DateTime.Now
                   }

                }
               :
               new JobPosting
               {
                   IdJobPost = "",
                   Title = "",
                   Description = "",
                   Requirements = "",
                   Salary = 0,
                   Location = "",
                   WorkType = "",
                   ExperienceLevel = "",
                   IdCompany = "",
                   ApplicationDeadline = DateTime.Now,
                   Benefits = "",
                   CreatedAt = DateTime.Now,
                   UpdatedAt = DateTime.Now,
                   PostStatus = "",
                   IsFeatured = 0,
                   Company = new Company
                   {
                       IdCompany = "",
                       CompanyName = "",
                       TaxCode = "",
                       Address = "",
                       Description = "",
                       LogoCompany = "",
                       WebsiteUrl = "",
                       Industry = "",
                       Scale = "",
                       BusinessLicenseUrl = "",
                       Status = "",
                       IsFeatured = 0,
                       CreatedAt = DateTime.Now,
                       UpdatedAt = DateTime.Now
                   }

               }
            });
        }

        // GET by job posting
        [HttpGet("jobposting/{jobPost}")]
        public async Task<ActionResult<IEnumerable<JobApplicationDto>>> GetByJob(string jobPost)
        {
            var list = await _context.JobApplications
                .Where(ja => ja.IdJobPost == jobPost)
                .Select(ja => new JobApplicationDto
                {
                    IdJobPost = ja.IdJobPost,
                    IdUser = ja.IdUser,
                    CvFileUrl = ja.CvFileUrl,
                    CoverLetter = ja.CoverLetter,
                    ApplicationStatus = ja.ApplicationStatus,
                    SubmittedAt = ja.SubmittedAt,
                    UpdatedAt = ja.UpdatedAt,
                    JobPosting = ja.JobPosting != null ? new JobPosting
                    {
                        IdJobPost = ja.JobPosting.IdJobPost,
                        Title = ja.JobPosting.Title,
                        Description = ja.JobPosting.Description,
                        Requirements = ja.JobPosting.Requirements,
                        Salary = ja.JobPosting.Salary,
                        Location = ja.JobPosting.Location,
                        WorkType = ja.JobPosting.WorkType,
                        ExperienceLevel = ja.JobPosting.ExperienceLevel,
                        IdCompany = ja.JobPosting.IdCompany,
                        ApplicationDeadline = ja.JobPosting.ApplicationDeadline,
                        Benefits = ja.JobPosting.Benefits,
                        CreatedAt = ja.JobPosting.CreatedAt,
                        UpdatedAt = ja.JobPosting.UpdatedAt,
                        PostStatus = ja.JobPosting.PostStatus,
                        IsFeatured = ja.JobPosting.IsFeatured,
                        Company = ja.JobPosting.Company != null ? new Company
                        {
                            IdCompany = ja.JobPosting.Company.IdCompany,
                            CompanyName = ja.JobPosting.Company.CompanyName,
                            TaxCode = ja.JobPosting.Company.TaxCode,
                            Address = ja.JobPosting.Company.Address,
                            Description = ja.JobPosting.Company.Description,
                            LogoCompany = ja.JobPosting.Company.LogoCompany,
                            WebsiteUrl = ja.JobPosting.Company.WebsiteUrl,
                            Scale = ja.JobPosting.Company.Scale,
                            Industry = ja.JobPosting.Company.Industry,
                            BusinessLicenseUrl = ja.JobPosting.Company.BusinessLicenseUrl,
                            Status = ja.JobPosting.Company.Status,
                            IsFeatured = ja.JobPosting.Company.IsFeatured,
                            CreatedAt = ja.JobPosting.Company.CreatedAt,
                            UpdatedAt = ja.JobPosting.Company.UpdatedAt,
                        }
                       : new Company
                       {
                           IdCompany = "",
                           CompanyName = "",
                           TaxCode = "",
                           Address = "",
                           Description = "",
                           LogoCompany = "",
                           WebsiteUrl = "",
                           Industry = "",
                           Scale = "",
                           BusinessLicenseUrl = "",
                           Status = "",
                           IsFeatured = 0,
                           CreatedAt = DateTime.Now,
                           UpdatedAt = DateTime.Now
                       }

                    }
               :
               new JobPosting
               {
                   IdJobPost = "",
                   Title = "",
                   Description = "",
                   Requirements = "",
                   Salary = 0,
                   Location = "",
                   WorkType = "",
                   ExperienceLevel = "",
                   IdCompany = "",
                   ApplicationDeadline = DateTime.Now,
                   Benefits = "",
                   CreatedAt = DateTime.Now,
                   UpdatedAt = DateTime.Now,
                   PostStatus = "",
                   IsFeatured = 0,
                   Company = new Company
                   {
                       IdCompany = "",
                       CompanyName = "",
                       TaxCode = "",
                       Address = "",
                       Description = "",
                       LogoCompany = "",
                       WebsiteUrl = "",
                       Industry = "",
                       Scale = "",
                       BusinessLicenseUrl = "",
                       Status = "",
                       IsFeatured = 0,
                       CreatedAt = DateTime.Now,
                       UpdatedAt = DateTime.Now
                   }

               }
                }).ToListAsync();

            if (list == null || list.Count == 0)
                return NotFound(new { message = "Không tìm thấy hồ sơ ứng tuyển cho job này." });

            return Ok(list);
        }


        // POST
        [HttpPost]
        public async Task<ActionResult<JobApplicationDto>> Create([FromBody] CreateJobApplicationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Check job & user tồn tại
            var job = await _context.JobPostings.FirstOrDefaultAsync(j => j.IdJobPost == dto.IdJobPost);
            if (job == null)
                return BadRequest(new { message = "Job posting không tồn tại." });

            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "User không tồn tại." });

            // Quá hạn nộp?
            if (job.ApplicationDeadline != null && job.ApplicationDeadline.Value.Date < DateTime.UtcNow.Date)
                return UnprocessableEntity(new { message = "Đã quá hạn nộp hồ sơ." });

            // Chống nộp trùng (khóa kép)
            var existed = await _context.JobApplications.FindAsync(dto.IdJobPost, dto.IdUser);
            if (existed != null)
                return Conflict(new { message = "Bạn đã nộp cho vị trí này." });

            var entity = new JobApplication
            {
                IdJobPost = dto.IdJobPost,
                IdUser = dto.IdUser,
                CvFileUrl = dto.CvFileUrl,
                CoverLetter = dto.CoverLetter,
                ApplicationStatus = string.IsNullOrWhiteSpace(dto.ApplicationStatus) ? "submitted" : dto.ApplicationStatus,
                SubmittedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.JobApplications.Add(entity);
            await _context.SaveChangesAsync();

            var result = new JobApplicationDto
            {
                IdJobPost = entity.IdJobPost,
                IdUser = entity.IdUser,
                CvFileUrl = entity.CvFileUrl,
                CoverLetter = entity.CoverLetter,
                ApplicationStatus = entity.ApplicationStatus,
                SubmittedAt = entity.SubmittedAt,
                UpdatedAt = entity.UpdatedAt
            };

            return CreatedAtAction(nameof(GetByKey), new { jobPost = result.IdJobPost, user = result.IdUser }, result);
        }


        // PUT (update)
        [HttpPut("{jobPost}/{user}")]
        public async Task<IActionResult> Update(
            string jobPost,
            string user,
            [FromBody] UpdateJobApplicationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.JobApplications.FindAsync(jobPost, user);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ ứng tuyển." });

            entity.CvFileUrl = dto.CvFileUrl ?? entity.CvFileUrl;
            entity.CoverLetter = dto.CoverLetter ?? entity.CoverLetter;
            entity.ApplicationStatus = dto.ApplicationStatus;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE
        [HttpDelete("{jobPost}/{user}")]
        public async Task<IActionResult> Delete(string jobPost, string user)
        {
            var entity = await _context.JobApplications.FindAsync(jobPost, user);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ ứng tuyển." });

            _context.JobApplications.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }


    }
}
