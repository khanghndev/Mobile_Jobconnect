using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InterviewScheduleController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public InterviewScheduleController(JobConnectDbContext context)
            => _context = context;

        // GET all
        [HttpGet]
        public async Task<ActionResult<IEnumerable<InterviewScheduleDto>>> GetAll()
        {
            var list = await _context.InterviewSchedules
                .Select(e => new InterviewScheduleDto
                {
                    IdSchedule = e.IdSchedule,
                    IdJobPost = e.IdJobPost,
                    IdUser = e.IdUser,
                    InterviewDate = e.InterviewDate,
                    InterviewMode = e.InterviewMode,
                    Location = e.Location,
                    Interviewer = e.Interviewer,
                    Note = e.Note
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET id
        [HttpGet("{id}")]
        public async Task<ActionResult<InterviewScheduleDto>> GetById(string id)
        {
            var dto = await _context.InterviewSchedules
                .Where(e => e.IdSchedule == id)
                .Select(e => new InterviewScheduleDto
                {
                    IdSchedule = e.IdSchedule,
                    IdJobPost = e.IdJobPost,
                    IdUser = e.IdUser,
                    InterviewDate = e.InterviewDate,
                    InterviewMode = e.InterviewMode,
                    Location = e.Location,
                    Interviewer = e.Interviewer,
                    Note = e.Note
                })
                .FirstOrDefaultAsync();

            if (dto == null)
                return NotFound(new { message = "Không tìm thấy lịch phỏng vấn." });

            return Ok(dto);
        }

        // GET: api/InterviewSchedule/jobposting/{idJobPost}
        [HttpGet("jobposting/{idJobPost}")]
        public async Task<ActionResult<IEnumerable<InterviewScheduleDto>>> GetByJobPostId(string idJobPost)
        {
            var list = await _context.InterviewSchedules
                .Where(e => e.IdJobPost == idJobPost)
                .Select(e => new InterviewScheduleDto
                {
                    IdSchedule = e.IdSchedule,
                    IdJobPost = e.IdJobPost,
                    IdUser = e.IdUser,
                    InterviewDate = e.InterviewDate,
                    InterviewMode = e.InterviewMode,
                    Location = e.Location,
                    Interviewer = e.Interviewer,
                    Note = e.Note
                })
                .ToListAsync();

            if (list == null || list.Count == 0)
                return NotFound(new { message = "Không có lịch phỏng vấn nào cho bài đăng tuyển dụng này." });

            return Ok(list);
        }

        // POST: api/InterviewSchedule
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateInterviewScheduleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra tồn tại JobApplication qua composite key
            var existsJA = await _context.JobApplications
                .AnyAsync(ja => ja.IdJobPost == dto.IdJobPost && ja.IdUser == dto.IdUser);
            if (!existsJA)
                return BadRequest(new { message = "Hồ sơ ứng tuyển không tồn tại." });

            var entity = new InterviewSchedule
            {
                IdSchedule = Guid.NewGuid().ToString(),
                IdJobPost = dto.IdJobPost,
                IdUser = dto.IdUser,
                InterviewDate = dto.InterviewDate,
                InterviewMode = dto.InterviewMode,
                Location = dto.Location,
                Interviewer = dto.Interviewer,
                Note = dto.Note
            };

            _context.InterviewSchedules.Add(entity);
            await _context.SaveChangesAsync();

            var resultDto = new InterviewScheduleDto
            {
                IdSchedule = entity.IdSchedule,
                IdJobPost = entity.IdJobPost,
                IdUser = entity.IdUser,
                InterviewDate = entity.InterviewDate,
                InterviewMode = entity.InterviewMode,
                Location = entity.Location,
                Interviewer = entity.Interviewer,
                Note = entity.Note
            };

            return CreatedAtAction(
                nameof(GetById),
                new { id = entity.IdSchedule },
                resultDto
            );
        }

        // PUT: api/InterviewSchedule/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateInterviewScheduleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.InterviewSchedules.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy lịch phỏng vấn." });

            entity.InterviewDate = dto.InterviewDate;
            entity.InterviewMode = dto.InterviewMode ?? entity.InterviewMode;
            entity.Location = dto.Location ?? entity.Location;
            entity.Interviewer = dto.Interviewer ?? entity.Interviewer;
            entity.Note = dto.Note ?? entity.Note;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/InterviewSchedule/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.InterviewSchedules.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy lịch phỏng vấn." });

            _context.InterviewSchedules.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
