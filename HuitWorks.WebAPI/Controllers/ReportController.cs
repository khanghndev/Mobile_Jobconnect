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
    public class ReportController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public ReportController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/Report
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ReportDto>>> GetAllReports()
        {
            var reports = await _context.Reports
                .Include(r => r.ReportType)
                .Select(r => new ReportDto
                {
                    ReportId = r.ReportId,
                    UserId = r.UserId,
                    ReportTypeId = r.ReportTypeId,
                    Title = r.Title,
                    Content = r.Content,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt,
                    ReportType = r.ReportType != null
                        ? new ReportTypeDto
                        {
                            ReportTypeId = r.ReportType.ReportTypeId,
                            Name = r.ReportType.Name,
                            Description = r.ReportType.Description,
                            CreatedDate = r.ReportType.CreatedDate
                        }
                        : null
                })
                .ToListAsync();

            return Ok(reports);
        }

        // GET: api/Report/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<ReportDto>> GetReportById(string id)
        {
            var report = await _context.Reports
                .Include(r => r.ReportType)
                .FirstOrDefaultAsync(r => r.ReportId == id);

            if (report == null)
                return NotFound(new { message = "Report not found." });

            var dto = new ReportDto
            {
                ReportId = report.ReportId,
                UserId = report.UserId,
                ReportTypeId = report.ReportTypeId,
                Title = report.Title,
                Content = report.Content,
                CreatedAt = report.CreatedAt,
                UpdatedAt = report.UpdatedAt,
                ReportType = report.ReportType != null
                    ? new ReportTypeDto
                    {
                        ReportTypeId = report.ReportType.ReportTypeId,
                        Name = report.ReportType.Name,
                        Description = report.ReportType.Description,
                        CreatedDate = report.ReportType.CreatedDate
                    }
                    : null
            };

            return Ok(dto);
        }

        // POST: api/Report
        [HttpPost]
        public async Task<ActionResult<ReportDto>> CreateReport([FromBody] CreateReportDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userExists = await _context.Users.AnyAsync(u => u.IdUser == dto.UserId);
            if (!userExists)
                return BadRequest(new { message = "User does not exist." });

            var typeExists = await _context.ReportTypes.AnyAsync(rt => rt.ReportTypeId == dto.ReportTypeId);
            if (!typeExists)
                return BadRequest(new { message = "ReportType does not exist." });

            var entity = new Report
            {
                ReportId = Guid.NewGuid().ToString(),
                UserId = dto.UserId,
                ReportTypeId = dto.ReportTypeId,
                Title = dto.Title,
                Content = dto.Content,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Reports.Add(entity);
            await _context.SaveChangesAsync();

            var rt = await _context.ReportTypes.FindAsync(entity.ReportTypeId)!;

            var resultDto = new ReportDto
            {
                ReportId = entity.ReportId,
                UserId = entity.UserId,
                ReportTypeId = entity.ReportTypeId,
                Title = entity.Title,
                Content = entity.Content,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ReportType = rt != null
                    ? new ReportTypeDto
                    {
                        ReportTypeId = rt.ReportTypeId,
                        Name = rt.Name,
                        Description = rt.Description,
                        CreatedDate = rt.CreatedDate
                    }
                    : null
            };

            return CreatedAtAction(nameof(GetReportById), new { id = entity.ReportId }, resultDto);
        }

        // PUT: api/Report/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReport(string id, [FromBody] UpdateReportDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.Reports.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Report not found." });

            var typeExists = await _context.ReportTypes.AnyAsync(rt => rt.ReportTypeId == dto.ReportTypeId);
            if (!typeExists)
                return BadRequest(new { message = "ReportType does not exist." });

            entity.ReportTypeId = dto.ReportTypeId;
            entity.Title = dto.Title ?? entity.Title;
            entity.Content = dto.Content ?? entity.Content;
            entity.UpdatedAt = DateTime.UtcNow;

            _context.Reports.Update(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/Report/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReport(string id)
        {
            var entity = await _context.Reports.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Report not found." });

            _context.Reports.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
