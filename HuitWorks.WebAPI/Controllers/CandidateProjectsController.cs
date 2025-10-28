using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CandidateProjectsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public CandidateProjectsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/candidateprojects
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CandidateProjectsDto>>> GetCandidateProjects()
        {
            var projects = await _context.CandidateProjects
                .Select(p => new CandidateProjectsDto
                {
                    IdProject = p.IdProject,
                    IdUser = p.IdUser,
                    ProjectName = p.ProjectName,
                    ProjectUrl = p.ProjectUrl,
                    Description = p.Description,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            return Ok(projects);
        }

        // GET: api/candidateprojects/user/{idUser}
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<CandidateProjectsDto>>> GetCandidateProjectsByUser(string idUser)
        {
            var projects = await _context.CandidateProjects
                .Where(p => p.IdUser == idUser)
                .OrderByDescending(p => p.CreatedAt)
                .Select(p => new CandidateProjectsDto
                {
                    IdProject = p.IdProject,
                    IdUser = p.IdUser,
                    ProjectName = p.ProjectName,
                    ProjectUrl = p.ProjectUrl,
                    Description = p.Description,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            return Ok(projects);
        }

        // GET: api/candidateprojects/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CandidateProjectsDto>> GetCandidateProject(string id)
        {
            var project = await _context.CandidateProjects
                .Where(p => p.IdProject == id)
                .Select(p => new CandidateProjectsDto
                {
                    IdProject = p.IdProject,
                    IdUser = p.IdUser,
                    ProjectName = p.ProjectName,
                    ProjectUrl = p.ProjectUrl,
                    Description = p.Description,
                    CreatedAt = p.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (project == null)
            {
                return NotFound("Không tìm thấy dự án");
            }

            return Ok(project);
        }

        // POST: api/candidateprojects
        [HttpPost]
        public async Task<ActionResult<CandidateProjectsDto>> CreateCandidateProject(CreateCandidateProjectsDto createDto)
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

            var project = new CandidateProjects
            {
                IdProject = Guid.NewGuid().ToString(),
                IdUser = createDto.IdUser,
                ProjectName = createDto.ProjectName,
                ProjectUrl = createDto.ProjectUrl,
                Description = createDto.Description,
                CreatedAt = DateTime.Now
            };

            _context.CandidateProjects.Add(project);
            await _context.SaveChangesAsync();

            var projectDto = new CandidateProjectsDto
            {
                IdProject = project.IdProject,
                IdUser = project.IdUser,
                ProjectName = project.ProjectName,
                ProjectUrl = project.ProjectUrl,
                Description = project.Description,
                CreatedAt = project.CreatedAt
            };

            return CreatedAtAction(nameof(GetCandidateProject), new { id = project.IdProject }, projectDto);
        }

        // PUT: api/candidateprojects/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCandidateProject(string id, UpdateCandidateProjectsDto updateDto)
        {
            if (id != updateDto.IdProject)
            {
                return BadRequest("ID không khớp");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var project = await _context.CandidateProjects.FindAsync(id);
            if (project == null)
            {
                return NotFound("Không tìm thấy dự án");
            }

            project.ProjectName = updateDto.ProjectName;
            project.ProjectUrl = updateDto.ProjectUrl;
            project.Description = updateDto.Description;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CandidateProjectExists(id))
                {
                    return NotFound("Không tìm thấy dự án");
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/candidateprojects/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCandidateProject(string id)
        {
            var project = await _context.CandidateProjects.FindAsync(id);
            if (project == null)
            {
                return NotFound("Không tìm thấy dự án");
            }

            _context.CandidateProjects.Remove(project);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CandidateProjectExists(string id)
        {
            return _context.CandidateProjects.Any(e => e.IdProject == id);
        }
    }
}
