using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JobSavedController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public JobSavedController(JobConnectDbContext context) => _context = context;

        // GET: api/JobSaved
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobSavedDto>>> GetAll()
        {
            var list = await _context.JobSaveds
                .Select(js => new JobSavedDto
                {
                    IdJobPost = js.IdJobPost,
                    IdUser = js.IdUser
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/JobSaved/jobposting/{jobPost}
        [HttpGet("jobposting/{jobPost}")]
        public async Task<ActionResult<IEnumerable<JobSavedDto>>> GetByJobPost(string jobPost)
        {
            var list = await _context.JobSaveds
                .Where(js => js.IdJobPost == jobPost)
                .Select(js => new JobSavedDto
                {
                    IdJobPost = js.IdJobPost,
                    IdUser = js.IdUser
                })
                .ToListAsync();

            if (list == null || list.Count == 0)
                return NotFound(new { message = "Không tìm thấy mục đã lưu cho job này." });

            return Ok(list);
        }

        // GET: api/JobSaved/user/{user}
        [HttpGet("user/{user}")]
        public async Task<ActionResult<IEnumerable<JobSavedDto>>> GetByUser(string user)
        {
            var list = await _context.JobSaveds
                .Where(js => js.IdUser == user)
                .Select(js => new JobSavedDto
                {
                    IdJobPost = js.IdJobPost,
                    IdUser = js.IdUser
                })
                .ToListAsync();

            if (list == null || list.Count == 0)
                return NotFound(new { message = "Không tìm thấy mục đã lưu cho user này." });

            return Ok(list);
        }

        // GET: api/JobSaved/{jobPost}/{user}
        [HttpGet("{jobPost}/{user}")]
        public async Task<ActionResult<JobSavedDto>> GetByKey(string jobPost, string user)
        {
            var js = await _context.JobSaveds.FindAsync(jobPost, user);
            if (js == null)
                return NotFound(new { message = "Không tìm thấy mục đã lưu." });

            return Ok(new JobSavedDto
            {
                IdJobPost = js.IdJobPost,
                IdUser = js.IdUser
            });
        }

        // POST: api/JobSaved
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateJobSavedDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra tồn tại JobPosting và User
            if (!await _context.JobPostings.AnyAsync(j => j.IdJobPost == dto.IdJobPost))
                return BadRequest(new { message = "Job posting không tồn tại." });
            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "User không tồn tại." });

            // Kiểm tra đã lưu chưa
            var exists = await _context.JobSaveds.FindAsync(dto.IdJobPost, dto.IdUser);
            if (exists != null)
                return Conflict(new { message = "Đã lưu công việc này cho người dùng." });

            var entity = new JobSaved
            {
                IdJobPost = dto.IdJobPost,
                IdUser = dto.IdUser
            };

            _context.JobSaveds.Add(entity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(
                nameof(GetByKey),
                new { jobPost = entity.IdJobPost, user = entity.IdUser },
                new JobSavedDto
                {
                    IdJobPost = entity.IdJobPost,
                    IdUser = entity.IdUser
                }
            );
        }

        // DELETE: api/JobSaved/{jobPost}/{user}
        [HttpDelete("{jobPost}/{user}")]
        public async Task<IActionResult> Delete(string jobPost, string user)
        {
            var entity = await _context.JobSaveds.FindAsync(jobPost, user);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy mục đã lưu." });

            _context.JobSaveds.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
