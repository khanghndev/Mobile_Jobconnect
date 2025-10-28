using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CandidateSkillsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public CandidateSkillsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/candidateskills
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CandidateSkillsDto>>> GetCandidateSkills()
        {
            var skills = await _context.CandidateSkills
                .Select(s => new CandidateSkillsDto
                {
                    IdSkill = s.IdSkill,
                    IdUser = s.IdUser,
                    SkillName = s.SkillName,
                    SkillLevel = s.SkillLevel
                })
                .ToListAsync();

            return Ok(skills);
        }

        // GET: api/candidateskills/user/{idUser}
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<CandidateSkillsDto>>> GetCandidateSkillsByUser(string idUser)
        {
            var skills = await _context.CandidateSkills
                .Where(s => s.IdUser == idUser)
                .Select(s => new CandidateSkillsDto
                {
                    IdSkill = s.IdSkill,
                    IdUser = s.IdUser,
                    SkillName = s.SkillName,
                    SkillLevel = s.SkillLevel
                })
                .ToListAsync();

            return Ok(skills);
        }

        // GET: api/candidateskills/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CandidateSkillsDto>> GetCandidateSkill(string id)
        {
            var skill = await _context.CandidateSkills
                .Where(s => s.IdSkill == id)
                .Select(s => new CandidateSkillsDto
                {
                    IdSkill = s.IdSkill,
                    IdUser = s.IdUser,
                    SkillName = s.SkillName,
                    SkillLevel = s.SkillLevel
                })
                .FirstOrDefaultAsync();

            if (skill == null)
            {
                return NotFound("Không tìm thấy kỹ năng");
            }

            return Ok(skill);
        }

        // POST: api/candidateskills
        [HttpPost]
        public async Task<ActionResult<CandidateSkillsDto>> CreateCandidateSkill(CreateCandidateSkillsDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra user có tồn tại không
            var userExists = await _context.Users.AnyAsync(u => u.IdUser == createDto.IdUser);
            if (!userExists)
            {
                return BadRequest("Người dùng không tồn tại");
            }

            var skill = new CandidateSkills
            {
                IdSkill = Guid.NewGuid().ToString(),
                IdUser = createDto.IdUser,
                SkillName = createDto.SkillName,
                SkillLevel = createDto.SkillLevel
            };

            _context.CandidateSkills.Add(skill);
            await _context.SaveChangesAsync();

            var skillDto = new CandidateSkillsDto
            {
                IdSkill = skill.IdSkill,
                IdUser = skill.IdUser,
                SkillName = skill.SkillName,
                SkillLevel = skill.SkillLevel
            };

            return CreatedAtAction(nameof(GetCandidateSkill), new { id = skill.IdSkill }, skillDto);
        }

        // PUT: api/candidateskills/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCandidateSkill(string id, UpdateCandidateSkillsDto updateDto)
        {
            if (id != updateDto.IdSkill)
            {
                return BadRequest("ID không khớp");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var skill = await _context.CandidateSkills.FindAsync(id);
            if (skill == null)
            {
                return NotFound("Không tìm thấy kỹ năng");
            }

            skill.SkillName = updateDto.SkillName;
            skill.SkillLevel = updateDto.SkillLevel;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CandidateSkillExists(id))
                {
                    return NotFound("Không tìm thấy kỹ năng");
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/candidateskills/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCandidateSkill(string id)
        {
            var skill = await _context.CandidateSkills.FindAsync(id);
            if (skill == null)
            {
                return NotFound("Không tìm thấy kỹ năng");
            }

            _context.CandidateSkills.Remove(skill);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CandidateSkillExists(string id)
        {
            return _context.CandidateSkills.Any(e => e.IdSkill == id);
        }
    }
}
