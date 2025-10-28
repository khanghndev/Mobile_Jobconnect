// File: Controllers/JobPostUsageLogController.cs
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
    public class JobPostUsageLogController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public JobPostUsageLogController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/JobPostUsageLog
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobPostUsageLogDto>>> GetAll()
        {
            var list = await _context.JobPostUsageLogs
                .Select(log => new JobPostUsageLogDto
                {
                    IdLog = log.IdLog,
                    IdTransaction = log.IdTransaction,
                    IdJobPost = log.IdJobPost,
                    UsedAt = log.UsedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/JobPostUsageLog/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<JobPostUsageLogDto>> GetById(string id)
        {
            var log = await _context.JobPostUsageLogs.FindAsync(id);
            if (log == null)
                return NotFound(new { message = "JobPostUsageLog not found." });

            var dto = new JobPostUsageLogDto
            {
                IdLog = log.IdLog,
                IdTransaction = log.IdTransaction,
                IdJobPost = log.IdJobPost,
                UsedAt = log.UsedAt
            };
            return Ok(dto);
        }

        // POST: api/JobPostUsageLog
        [HttpPost]
        public async Task<ActionResult<JobPostUsageLogDto>> Create([FromBody] CreateJobPostUsageLogDto dto)
        {
            var newId = Guid.NewGuid().ToString();
            if (await _context.JobPostUsageLogs.AnyAsync(x => x.IdLog == newId))
                return Conflict(new { message = "GUID collision, please try again." });

            var txExists = await _context.JobTransactions.AnyAsync(t => t.IdTransaction == dto.IdTransaction);
            if (!txExists)
                return BadRequest(new { message = "Referenced JobTransaction does not exist." });

            if (!string.IsNullOrEmpty(dto.IdJobPost))
            {
                var jobExists = await _context.JobPostings.AnyAsync(j => j.IdJobPost == dto.IdJobPost);
                if (!jobExists)
                    return BadRequest(new { message = "Referenced JobPosting does not exist." });
            }

            var usedAt = dto.UsedAt ?? DateTime.UtcNow;
            var entity = new JobPostUsageLog
            {
                IdLog = newId,
                IdTransaction = dto.IdTransaction,
                IdJobPost = dto.IdJobPost,
                UsedAt = usedAt
            };

            _context.JobPostUsageLogs.Add(entity);
            await _context.SaveChangesAsync();

            var createdDto = new JobPostUsageLogDto
            {
                IdLog = entity.IdLog,
                IdTransaction = entity.IdTransaction,
                IdJobPost = entity.IdJobPost,
                UsedAt = entity.UsedAt
            };

            return CreatedAtAction(nameof(GetById), new { id = createdDto.IdLog }, createdDto);
        }

        // PUT: api/JobPostUsageLog/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateJobPostUsageLogDto dto)
        {
            var entity = await _context.JobPostUsageLogs.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "JobPostUsageLog not found." });

            if (dto.IdJobPost != null)
            {
                var jobExists = await _context.JobPostings.AnyAsync(j => j.IdJobPost == dto.IdJobPost);
                if (!jobExists)
                    return BadRequest(new { message = "Referenced JobPosting does not exist." });
                entity.IdJobPost = dto.IdJobPost;
            }

            entity.UsedAt = dto.UsedAt ?? entity.UsedAt;

            _context.JobPostUsageLogs.Update(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/JobPostUsageLog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.JobPostUsageLogs.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "JobPostUsageLog not found." });

            _context.JobPostUsageLogs.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
