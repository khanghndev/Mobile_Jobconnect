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
    public class ReportTypeController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public ReportTypeController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/ReportType
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ReportTypeDto>>> GetAllReportTypes()
        {
            var types = await _context.ReportTypes
                .Select(rt => new ReportTypeDto
                {
                    ReportTypeId = rt.ReportTypeId,
                    Name = rt.Name,
                    Description = rt.Description,
                    CreatedDate = rt.CreatedDate
                })
                .ToListAsync();

            return Ok(types);
        }

        // GET: api/ReportType/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<ReportTypeDto>> GetReportType(int id)
        {
            var rt = await _context.ReportTypes.FindAsync(id);
            if (rt == null)
            {
                return NotFound(new { message = "ReportType not found." });
            }

            var dto = new ReportTypeDto
            {
                ReportTypeId = rt.ReportTypeId,
                Name = rt.Name,
                Description = rt.Description,
                CreatedDate = rt.CreatedDate
            };

            return Ok(dto);
        }

        // POST: api/ReportType
        [HttpPost]
        public async Task<ActionResult<ReportTypeDto>> CreateReportType([FromBody] CreateReportTypeDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = new ReportType
            {
                Name = dto.Name,
                Description = dto.Description,
                CreatedDate = DateTime.UtcNow
            };

            _context.ReportTypes.Add(entity);
            await _context.SaveChangesAsync();

            var resultDto = new ReportTypeDto
            {
                ReportTypeId = entity.ReportTypeId,
                Name = entity.Name,
                Description = entity.Description,
                CreatedDate = entity.CreatedDate
            };

            return CreatedAtAction(nameof(GetReportType), new { id = entity.ReportTypeId }, resultDto);
        }

        // PUT: api/ReportType/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReportType(int id, [FromBody] UpdateReportTypeDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.ReportTypes.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "ReportType not found." });

            entity.Name = dto.Name;
            entity.Description = dto.Description;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/ReportType/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReportType(int id)
        {
            var entity = await _context.ReportTypes.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "ReportType not found." });

            _context.ReportTypes.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
