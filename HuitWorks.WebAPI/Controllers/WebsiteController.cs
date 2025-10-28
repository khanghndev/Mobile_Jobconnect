using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WebsiteController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public WebsiteController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/website
        [HttpGet]
        public async Task<ActionResult<IEnumerable<WebsiteDto>>> GetAll()
        {
            var list = await _context.Websites
                .Select(w => new WebsiteDto
                {
                    IdWebsite = w.IdWebsite,
                    Name = w.Name,
                    Url = w.Url,
                    Description = w.Description,
                    IsActive = w.IsActive,
                    CreatedAt = w.CreatedAt,
                    UpdatedAt = w.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/website/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<WebsiteDto>> GetById(string id)
        {
            var dto = await _context.Websites
                .Where(w => w.IdWebsite == id)
                .Select(w => new WebsiteDto
                {
                    IdWebsite = w.IdWebsite,
                    Name = w.Name,
                    Url = w.Url,
                    Description = w.Description,
                    IsActive = w.IsActive,
                    CreatedAt = w.CreatedAt,
                    UpdatedAt = w.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (dto == null)
                return NotFound(new { message = "Không tìm thấy website." });

            return Ok(dto);
        }

        // POST: api/website
        [HttpPost]
        public async Task<ActionResult<WebsiteDto>> Create([FromBody] CreateWebsiteDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = new Website
            {
                IdWebsite = "web" + Guid.NewGuid(),
                Name = dto.Name,
                Url = dto.Url,
                Description = dto.Description,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Websites.Add(entity);
            await _context.SaveChangesAsync();

            var result = new WebsiteDto
            {
                IdWebsite = entity.IdWebsite,
                Name = entity.Name,
                Url = entity.Url,
                Description = entity.Description,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };

            return CreatedAtAction(nameof(GetById), new { id = result.IdWebsite }, result);
        }

        // PUT: api/website/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateWebsiteDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.Websites.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy website." });

            entity.Name = dto.Name ?? entity.Name;
            entity.Url = dto.Url ?? entity.Url;
            entity.Description = dto.Description ?? entity.Description;
            entity.IsActive = dto.IsActive ?? entity.IsActive;
            entity.UpdatedAt = DateTime.UtcNow;

            _context.Websites.Update(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/website/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.Websites.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy website." });

            _context.Websites.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
