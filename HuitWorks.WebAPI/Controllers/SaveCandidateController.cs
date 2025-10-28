using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SaveCandidateController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SaveCandidateController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/savecandidate
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SaveCandidateDto>>> GetAll()
        {
            var list = await _context.SaveCandidates
                .Select(sc => new SaveCandidateDto
                {
                    IdUserRecruiter = sc.IdUserRecruiter,
                    IdUserCandidate = sc.IdUserCandidate,
                    SavedAt = sc.SavedAt,
                    Note = sc.Note
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/savecandidate/{idUserRecruiter}/{idUserCandidate}
        [HttpGet("{idUserRecruiter}/{idUserCandidate}")]
        public async Task<ActionResult<SaveCandidateDto>> GetById(string idUserRecruiter, string idUserCandidate)
        {
            var entity = await _context.SaveCandidates
                .Where(sc => sc.IdUserRecruiter == idUserRecruiter && sc.IdUserCandidate == idUserCandidate)
                .Select(sc => new SaveCandidateDto
                {
                    IdUserRecruiter = sc.IdUserRecruiter,
                    IdUserCandidate = sc.IdUserCandidate,
                    SavedAt = sc.SavedAt,
                    Note = sc.Note
                })
                .FirstOrDefaultAsync();

            if (entity == null)
                return NotFound(new { message = "Không tìm thấy bản ghi lưu ứng viên." });

            return Ok(entity);
        }

        // POST: api/savecandidate
        [HttpPost]
        public async Task<ActionResult<SaveCandidateDto>> Create([FromBody] CreateSaveCandidateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra recruiter và candidate có tồn tại không
            bool recruiterExists = await _context.Users.AnyAsync(u => u.IdUser == dto.IdUserRecruiter);
            bool candidateExists = await _context.Users.AnyAsync(u => u.IdUser == dto.IdUserCandidate);

            if (!recruiterExists)
                return BadRequest(new { message = "Người tuyển dụng không tồn tại." });

            if (!candidateExists)
                return BadRequest(new { message = "Ứng viên không tồn tại." });

            // Kiểm tra xem đã lưu chưa
            bool alreadySaved = await _context.SaveCandidates
                .AnyAsync(sc => sc.IdUserRecruiter == dto.IdUserRecruiter && sc.IdUserCandidate == dto.IdUserCandidate);

            if (alreadySaved)
                return Conflict(new { message = "Ứng viên đã được lưu bởi nhà tuyển dụng này." });

            var entity = new SaveCandidate
            {
                IdUserRecruiter = dto.IdUserRecruiter,
                IdUserCandidate = dto.IdUserCandidate,
                Note = dto.Note
            };

            _context.SaveCandidates.Add(entity);
            await _context.SaveChangesAsync();

            var result = new SaveCandidateDto
            {
                IdUserRecruiter = entity.IdUserRecruiter,
                IdUserCandidate = entity.IdUserCandidate,
                SavedAt = entity.SavedAt,
                Note = entity.Note
            };

            return CreatedAtAction(nameof(GetById), new { idUserRecruiter = result.IdUserRecruiter, idUserCandidate = result.IdUserCandidate }, result);
        }

        // PUT: api/savecandidate/{idUserRecruiter}/{idUserCandidate}
        [HttpPut("{idUserRecruiter}/{idUserCandidate}")]
        public async Task<IActionResult> Update(string idUserRecruiter, string idUserCandidate, [FromBody] UpdateSaveCandidateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existing = await _context.SaveCandidates.FindAsync(idUserRecruiter, idUserCandidate);
            if (existing == null)
                return NotFound(new { message = "Không tìm thấy bản ghi lưu ứng viên." });

            existing.Note = dto.Note ?? existing.Note;

            _context.SaveCandidates.Update(existing);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/savecandidate/{idUserRecruiter}/{idUserCandidate}
        [HttpDelete("{idUserRecruiter}/{idUserCandidate}")]
        public async Task<IActionResult> Delete(string idUserRecruiter, string idUserCandidate)
        {
            var existing = await _context.SaveCandidates.FindAsync(idUserRecruiter, idUserCandidate);
            if (existing == null)
                return NotFound(new { message = "Không tìm thấy bản ghi lưu ứng viên." });

            _context.SaveCandidates.Remove(existing);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
