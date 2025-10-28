using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResumeSkillController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public ResumeSkillController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/resumeSkill
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ResumeSkillDto>>> GetAll()
        {
            var list = await _context.ResumeSkills
                .Select(rs => new ResumeSkillDto
                {
                    IdResume = rs.IdResume,
                    Skill = rs.Skill,
                    Proficiency = rs.Proficiency
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/resumeSkill/{idResume}
        [HttpGet("{idResume}")]
        public async Task<ActionResult<IEnumerable<ResumeSkillDto>>> GetByResume(string idResume)
        {
            var list = await _context.ResumeSkills
                .Where(rs => rs.IdResume == idResume)
                .Select(rs => new ResumeSkillDto
                {
                    IdResume = rs.IdResume,
                    Skill = rs.Skill,
                    Proficiency = rs.Proficiency
                })
                .ToListAsync();

            if (!list.Any())
                return NotFound(new { message = "Không tìm thấy kỹ năng nào cho hồ sơ này." });

            return Ok(list);
        }

        // POST: api/resumeSkill
        [HttpPost]
        public async Task<ActionResult<ResumeSkillDto>> Create([FromBody] CreateResumeSkillDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // kiểm tra resume tồn tại
            if (!await _context.Resumes.AnyAsync(r => r.IdResume == dto.IdResume))
                return BadRequest(new { message = "Hồ sơ không tồn tại." });

            var entity = new ResumeSkill
            {
                IdResume = dto.IdResume,
                Skill = dto.Skill,
                Proficiency = dto.Proficiency
            };

            _context.ResumeSkills.Add(entity);
            await _context.SaveChangesAsync();

            var result = new ResumeSkillDto
            {
                IdResume = entity.IdResume,
                Skill = entity.Skill,
                Proficiency = entity.Proficiency
            };

            return Ok(result);
        }

        // PUT: api/resumeSkill
        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateResumeSkillDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.ResumeSkills
                .FirstOrDefaultAsync(rs => rs.IdResume == dto.IdResume && rs.Skill == dto.Skill);

            if (entity == null)
                return NotFound(new { message = "Không tìm thấy kỹ năng ứng với hồ sơ." });

            entity.Proficiency = dto.Proficiency ?? entity.Proficiency;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // Trong JobTransactionController của WebAPI
        [HttpPut("{id}/use-cvview")]
        public async Task<IActionResult> UseCvView(string id)
        {
            var tx = await _context.JobTransactions.FindAsync(id);
            if (tx == null)
                return NotFound(new { message = "JobTransaction not found." });

            if (tx.Status != "Completed" || tx.ExpiryDate < DateTime.UtcNow)
                return BadRequest(new { message = "Giao dịch chưa hoàn tất hoặc đã hết hạn." });

            if (tx.RemainingCvViews <= 0)
                return BadRequest(new { message = "Bạn đã hết lượt xem hồ sơ trong gói này." });

            tx.RemainingCvViews -= 1;
            _context.Entry(tx).Property(x => x.RemainingCvViews).IsModified = true;
            await _context.SaveChangesAsync();

            return NoContent();
        }


        // DELETE: api/resumeSkill/{idResume}/{skill}
        [HttpDelete("{idResume}/{skill}")]
        public async Task<IActionResult> Delete(string idResume, string skill)
        {
            var entity = await _context.ResumeSkills
                .FirstOrDefaultAsync(rs => rs.IdResume == idResume && rs.Skill == skill);

            if (entity == null)
                return NotFound(new { message = "Không tìm thấy kỹ năng ứng với hồ sơ." });

            _context.ResumeSkills.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
