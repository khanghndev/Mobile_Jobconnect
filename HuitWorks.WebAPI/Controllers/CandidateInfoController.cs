using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CandidateInfoController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public CandidateInfoController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/candidateinfo
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CandidateInfoDto>>> GetAll()
        {
            var list = await _context.CandidateInfo
                .Select(ci => new CandidateInfoDto
                {
                    IdUser = ci.IdUser,
                    WorkPosition = ci.WorkPosition,
                    RatingScore = ci.RatingScore,
                    UniversityName = ci.UniversityName,
                    EducationLevel = ci.EducationLevel,
                    ExperienceYears = ci.ExperienceYears,
                    Skills = ci.Skills,
                    FreeTime = ci.FreeTime,
                    PortfolioUrl = ci.PortfolioUrl
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/candidateinfo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CandidateInfoDto>> GetById(string id)
        {
            var ci = await _context.CandidateInfo
                .Where(c => c.IdUser == id)
                .Select(c => new CandidateInfoDto
                {
                    IdUser = c.IdUser,
                    WorkPosition = c.WorkPosition,
                    RatingScore = c.RatingScore,
                    UniversityName = c.UniversityName,
                    EducationLevel = c.EducationLevel,
                    ExperienceYears = c.ExperienceYears,
                    Skills = c.Skills,
                    FreeTime = c.FreeTime,
                    PortfolioUrl = c.PortfolioUrl
                })
                .FirstOrDefaultAsync();

            if (ci == null)
                return NotFound(new { message = "Không tìm thấy thông tin ứng viên." });

            return Ok(ci);
        }

        // POST: api/candidateinfo
        [HttpPost]
        public async Task<ActionResult<CandidateInfoDto>> Create([FromBody] CreateCandidateInfoDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // kiểm tra user tồn tại
            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new CandidateInfo
            {
                IdUser = dto.IdUser,
                WorkPosition = dto.WorkPosition,
                RatingScore = dto.RatingScore,
                UniversityName = dto.UniversityName,
                EducationLevel = dto.EducationLevel,
                ExperienceYears = dto.ExperienceYears,
                Skills = dto.Skills,
                FreeTime = dto.FreeTime,
                PortfolioUrl = dto.PortfolioUrl
            };

            _context.CandidateInfo.Add(entity);
            await _context.SaveChangesAsync();

            var result = new CandidateInfoDto
            {
                IdUser = entity.IdUser,
                WorkPosition = entity.WorkPosition,
                RatingScore = entity.RatingScore,
                UniversityName = entity.UniversityName,
                EducationLevel = entity.EducationLevel,
                ExperienceYears = entity.ExperienceYears,
                Skills = entity.Skills,
                FreeTime = entity.FreeTime,
                PortfolioUrl = entity.PortfolioUrl
            };

            return CreatedAtAction(nameof(GetById), new { id = result.IdUser }, result);
        }

        // PUT: api/candidateinfo/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateCandidateInfoDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existing = await _context.CandidateInfo.FindAsync(id);
            if (existing == null)
                return NotFound(new { message = "Không tìm thấy thông tin ứng viên." });

            existing.WorkPosition = dto.WorkPosition ?? existing.WorkPosition;
            existing.RatingScore = dto.RatingScore ?? existing.RatingScore;
            existing.UniversityName = dto.UniversityName ?? existing.UniversityName;
            existing.EducationLevel = dto.EducationLevel ?? existing.EducationLevel;
            existing.ExperienceYears = dto.ExperienceYears ?? existing.ExperienceYears;
            existing.Skills = dto.Skills ?? existing.Skills;
            existing.FreeTime = dto.FreeTime ?? existing.FreeTime;
            existing.PortfolioUrl = dto.PortfolioUrl ?? existing.PortfolioUrl;

            _context.CandidateInfo.Update(existing);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/candidateinfo/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var existing = await _context.CandidateInfo.FindAsync(id);
            if (existing == null)
                return NotFound(new { message = "Không tìm thấy thông tin ứng viên." });

            _context.CandidateInfo.Remove(existing);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
