// Controllers/SavedResumeController.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SavedResumeController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public SavedResumeController(JobConnectDbContext context) => _context = context;

        // GET: api/SavedResume
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SavedResumeDto>>> GetAll()
        {
            var list = await _context.SavedResumes
                .Select(e => new SavedResumeDto
                {
                    IdSave = e.IdSave,
                    IdRecruiter = e.IdRecruiter,
                    IdCandidate = e.IdCandidate,
                    SavedAt = e.SavedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/SavedResume/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<SavedResumeDto>> GetById(string id)
        {
            var dto = await _context.SavedResumes
                .Where(e => e.IdSave == id)
                .Select(e => new SavedResumeDto
                {
                    IdSave = e.IdSave,
                    IdRecruiter = e.IdRecruiter,
                    IdCandidate = e.IdCandidate,
                    SavedAt = e.SavedAt
                })
                .FirstOrDefaultAsync();

            return dto == null ? NotFound() : Ok(dto);
        }

        // POST: api/SavedResume
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateSavedResumeDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = new SavedResume
            {
                IdSave = Guid.NewGuid().ToString(),
                IdRecruiter = dto.IdRecruiter,
                IdCandidate = dto.IdCandidate,
                SavedAt = dto.SavedAt ?? DateTime.UtcNow
            };

            _context.SavedResumes.Add(entity);
            await _context.SaveChangesAsync();

            var resultDto = new SavedResumeDto
            {
                IdSave = entity.IdSave,
                IdRecruiter = entity.IdRecruiter,
                IdCandidate = entity.IdCandidate,
                SavedAt = entity.SavedAt
            };

            return CreatedAtAction(nameof(GetById), new { id = entity.IdSave }, resultDto);
        }

        // DELETE: api/SavedResume/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var existing = await _context.SavedResumes.FindAsync(id);
            if (existing == null)
                return NotFound();

            _context.SavedResumes.Remove(existing);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
