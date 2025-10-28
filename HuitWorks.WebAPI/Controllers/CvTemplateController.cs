using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CvTemplateController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly ILogger<CvTemplateController> _logger;

        public CvTemplateController(JobConnectDbContext context, ILogger<CvTemplateController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet("test")]
        [AllowAnonymous]
        public IActionResult Test()
        {
            return Ok(new { message = "API is working", timestamp = DateTime.Now });
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<CvTemplateDto>>> GetTemplates()
        {
            try
            {
                // Test database connection first
                var canConnect = await _context.Database.CanConnectAsync();
                if (!canConnect)
                {
                    _logger.LogError("Cannot connect to database");
                    return StatusCode(500, "Database connection failed");
                }

                var templates = await _context.CvTemplates
                    .Where(t => t.IsActive)
                    .OrderBy(t => t.Name)
                    .Select(t => new CvTemplateDto
                    {
                        IdTemplate = t.IdTemplate,
                        Slug = t.Slug,
                        Name = t.Name,
                        Engine = t.Engine,
                        PreviewUrl = t.PreviewUrl,
                        IsActive = t.IsActive,
                        CreatedAt = t.CreatedAt,
                        UpdatedAt = t.UpdatedAt
                    })
                    .ToListAsync();

                _logger.LogInformation($"Retrieved {templates.Count} templates");
                return Ok(templates);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving CV templates: {Message}", ex.Message);
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<CvTemplateDto>> GetTemplate(string id)
        {
            try
            {
                var template = await _context.CvTemplates
                    .Where(t => t.IdTemplate == id && t.IsActive)
                    .Select(t => new CvTemplateDto
                    {
                        IdTemplate = t.IdTemplate,
                        Slug = t.Slug,
                        Name = t.Name,
                        Engine = t.Engine,
                        PreviewUrl = t.PreviewUrl,
                        IsActive = t.IsActive,
                        CreatedAt = t.CreatedAt,
                        UpdatedAt = t.UpdatedAt
                    })
                    .FirstOrDefaultAsync();

                if (template == null)
                {
                    return NotFound();
                }

                return Ok(template);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving CV template {TemplateId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<CvTemplateDto>> CreateTemplate([FromBody] CvTemplateDto templateDto)
        {
            try
            {
                var template = new CvTemplate
                {
                    IdTemplate = Guid.NewGuid().ToString(),
                    Slug = templateDto.Slug,
                    Name = templateDto.Name,
                    Engine = templateDto.Engine,
                    PreviewUrl = templateDto.PreviewUrl,
                    IsActive = templateDto.IsActive,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };

                _context.CvTemplates.Add(template);
                await _context.SaveChangesAsync();

                templateDto.IdTemplate = template.IdTemplate;
                templateDto.CreatedAt = template.CreatedAt;
                templateDto.UpdatedAt = template.UpdatedAt;

                return CreatedAtAction(nameof(GetTemplate), new { id = template.IdTemplate }, templateDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating CV template");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateTemplate(string id, [FromBody] CvTemplateDto templateDto)
        {
            try
            {
                var template = await _context.CvTemplates.FindAsync(id);
                if (template == null)
                {
                    return NotFound();
                }

                template.Slug = templateDto.Slug;
                template.Name = templateDto.Name;
                template.Engine = templateDto.Engine;
                template.PreviewUrl = templateDto.PreviewUrl;
                template.IsActive = templateDto.IsActive;
                template.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating CV template {TemplateId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteTemplate(string id)
        {
            try
            {
                var template = await _context.CvTemplates.FindAsync(id);
                if (template == null)
                {
                    return NotFound();
                }

                template.IsActive = false;
                template.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting CV template {TemplateId}", id);
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
