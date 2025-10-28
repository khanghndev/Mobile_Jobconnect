// File: Controllers/CvViewUsageLogController.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CvViewUsageLogController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public CvViewUsageLogController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/CvViewUsageLog
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CvViewUsageLogDto>>> GetAll()
        {
            var list = await _context.CvViewUsageLogs
                .Select(log => new CvViewUsageLogDto
                {
                    IdLog = log.IdLog,
                    IdTransaction = log.IdTransaction,
                    IdResume = log.IdResume,
                    UsedAt = log.UsedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/CvViewUsageLog/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CvViewUsageLogDto>> GetById(string id)
        {
            var log = await _context.CvViewUsageLogs.FindAsync(id);
            if (log == null)
                return NotFound(new { message = "CvViewUsageLog not found." });

            var dto = new CvViewUsageLogDto
            {
                IdLog = log.IdLog,
                IdTransaction = log.IdTransaction,
                IdResume = log.IdResume,
                UsedAt = log.UsedAt
            };
            return Ok(dto);
        }

        // POST: api/CvViewUsageLog
        [HttpPost]
        public async Task<ActionResult<CvViewUsageLogDto>> Create([FromBody] CreateCvViewUsageLogDto dto)
        {
            var newId = Guid.NewGuid().ToString();
            if (await _context.CvViewUsageLogs.AnyAsync(x => x.IdLog == newId))
                return Conflict(new { message = "GUID collision, please try again." });

            var txExists = await _context.JobTransactions.AnyAsync(t => t.IdTransaction == dto.IdTransaction);
            if (!txExists)
                return BadRequest(new { message = "Referenced JobTransaction does not exist." });

            if (!string.IsNullOrEmpty(dto.IdResume))
            {
                var resumeExists = await _context.Resumes.AnyAsync(r => r.IdResume == dto.IdResume);
                if (!resumeExists)
                    return BadRequest(new { message = "Referenced Resume does not exist." });
            }

            var usedAt = dto.UsedAt ?? DateTime.UtcNow;
            var entity = new CvViewUsageLog
            {
                IdLog = newId,
                IdTransaction = dto.IdTransaction,
                IdResume = dto.IdResume,
                UsedAt = usedAt
            };

            _context.CvViewUsageLogs.Add(entity);
            await _context.SaveChangesAsync();

            var createdDto = new CvViewUsageLogDto
            {
                IdLog = entity.IdLog,
                IdTransaction = entity.IdTransaction,
                IdResume = entity.IdResume,
                UsedAt = entity.UsedAt
            };

            return CreatedAtAction(nameof(GetById), new { id = createdDto.IdLog }, createdDto);
        }

        // PUT: api/CvViewUsageLog/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateCvViewUsageLogDto dto)
        {
            var entity = await _context.CvViewUsageLogs.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "CvViewUsageLog not found." });

            if (dto.IdResume != null)
            {
                var resumeExists = await _context.Resumes.AnyAsync(r => r.IdResume == dto.IdResume);
                if (!resumeExists)
                    return BadRequest(new { message = "Referenced Resume does not exist." });
                entity.IdResume = dto.IdResume;
            }

            entity.UsedAt = dto.UsedAt ?? entity.UsedAt;

            _context.CvViewUsageLogs.Update(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/CvViewUsageLog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.CvViewUsageLogs.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "CvViewUsageLog not found." });

            _context.CvViewUsageLogs.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
