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
    [Authorize]
    public class CvDocumentController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly ICvRenderService _cvRenderService;
        private readonly ILogger<CvDocumentController> _logger;

        public CvDocumentController(JobConnectDbContext context, ICvRenderService cvRenderService, ILogger<CvDocumentController> logger)
        {
            _context = context;
            _cvRenderService = cvRenderService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<CvDocumentDto>>> GetDocuments()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var documents = await _context.CvDocuments
                    .Where(d => d.IdUser == userId)
                    .Include(d => d.Template)
                    .OrderByDescending(d => d.UpdatedAt)
                    .ToListAsync();

                var documentDtos = documents.Select(d => new CvDocumentDto
                {
                    IdDocument = d.IdDocument,
                    IdUser = d.IdUser,
                    IdTemplate = d.IdTemplate,
                    Title = d.Title,
                    Locale = d.Locale,
                    ColorScheme = d.ColorScheme,
                    Content = JsonSerializer.Deserialize<CvContentDto>(d.ContentJson),
                    Status = d.Status,
                    CreatedAt = d.CreatedAt,
                    UpdatedAt = d.UpdatedAt,
                    Template = new CvTemplateDto
                    {
                        IdTemplate = d.Template.IdTemplate,
                        Slug = d.Template.Slug,
                        Name = d.Template.Name,
                        Engine = d.Template.Engine,
                        PreviewUrl = d.Template.PreviewUrl,
                        IsActive = d.Template.IsActive,
                        CreatedAt = d.Template.CreatedAt,
                        UpdatedAt = d.Template.UpdatedAt
                    }
                }).ToList();

                return Ok(documentDtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving CV documents");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<CvDocumentDto>> GetDocument(string id)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var entity = await _context.CvDocuments
                    .Where(d => d.IdDocument == id && d.IdUser == userId)
                    .Include(d => d.Template)
                    .FirstOrDefaultAsync();

                if (entity == null)
                {
                    return NotFound();
                }

                var document = new CvDocumentDto
                {
                    IdDocument = entity.IdDocument,
                    IdUser = entity.IdUser,
                    IdTemplate = entity.IdTemplate,
                    Title = entity.Title,
                    Locale = entity.Locale,
                    ColorScheme = entity.ColorScheme,
                    Content = JsonSerializer.Deserialize<CvContentDto>(entity.ContentJson),
                    Status = entity.Status,
                    CreatedAt = entity.CreatedAt,
                    UpdatedAt = entity.UpdatedAt,
                    Template = new CvTemplateDto
                    {
                        IdTemplate = entity.Template.IdTemplate,
                        Slug = entity.Template.Slug,
                        Name = entity.Template.Name,
                        Engine = entity.Template.Engine,
                        PreviewUrl = entity.Template.PreviewUrl,
                        IsActive = entity.Template.IsActive,
                        CreatedAt = entity.Template.CreatedAt,
                        UpdatedAt = entity.Template.UpdatedAt
                    }
                };

                return Ok(document);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving CV document {DocumentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<CvDocumentDto>> CreateDocument([FromBody] CreateCvDocumentDto createDto)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                // Verify template exists
                var template = await _context.CvTemplates
                    .Where(t => t.IdTemplate == createDto.IdTemplate && t.IsActive)
                    .FirstOrDefaultAsync();

                if (template == null)
                {
                    return BadRequest("Template not found or inactive");
                }

                var document = new CvDocument
                {
                    IdDocument = Guid.NewGuid().ToString(),
                    IdUser = userId,
                    IdTemplate = createDto.IdTemplate,
                    Title = createDto.Title,
                    Locale = createDto.Locale,
                    ColorScheme = createDto.ColorScheme,
                    ContentJson = JsonSerializer.Serialize(createDto.Content),
                    Status = CvDocumentStatus.Draft,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };

                _context.CvDocuments.Add(document);
                await _context.SaveChangesAsync();

                var documentDto = new CvDocumentDto
                {
                    IdDocument = document.IdDocument,
                    IdUser = document.IdUser,
                    IdTemplate = document.IdTemplate,
                    Title = document.Title,
                    Locale = document.Locale,
                    ColorScheme = document.ColorScheme,
                    Content = createDto.Content,
                    Status = document.Status,
                    CreatedAt = document.CreatedAt,
                    UpdatedAt = document.UpdatedAt,
                    Template = new CvTemplateDto
                    {
                        IdTemplate = template.IdTemplate,
                        Slug = template.Slug,
                        Name = template.Name,
                        Engine = template.Engine,
                        PreviewUrl = template.PreviewUrl,
                        IsActive = template.IsActive,
                        CreatedAt = template.CreatedAt,
                        UpdatedAt = template.UpdatedAt
                    }
                };

                return CreatedAtAction(nameof(GetDocument), new { id = document.IdDocument }, documentDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating CV document");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateDocument(string id, [FromBody] UpdateCvDocumentDto updateDto)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var document = await _context.CvDocuments
                    .Where(d => d.IdDocument == id && d.IdUser == userId)
                    .FirstOrDefaultAsync();

                if (document == null)
                {
                    return NotFound();
                }

                if (updateDto.Title != null)
                    document.Title = updateDto.Title;

                if (updateDto.ColorScheme != null)
                    document.ColorScheme = updateDto.ColorScheme;

                if (updateDto.Content != null)
                    document.ContentJson = JsonSerializer.Serialize(updateDto.Content);

                if (updateDto.Status.HasValue)
                    document.Status = updateDto.Status.Value;

                document.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating CV document {DocumentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDocument(string id)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var document = await _context.CvDocuments
                    .Where(d => d.IdDocument == id && d.IdUser == userId)
                    .FirstOrDefaultAsync();

                if (document == null)
                {
                    return NotFound();
                }

                _context.CvDocuments.Remove(document);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting CV document {DocumentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/export")]
        public async Task<ActionResult<CvExportDto>> ExportDocument(string id, [FromBody] CreateCvExportDto exportDto)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var document = await _context.CvDocuments
                    .Where(d => d.IdDocument == id && d.IdUser == userId)
                    .Include(d => d.Template)
                    .FirstOrDefaultAsync();

                if (document == null)
                {
                    return NotFound();
                }

                var documentDto = new CvDocumentDto
                {
                    IdDocument = document.IdDocument,
                    IdUser = document.IdUser,
                    IdTemplate = document.IdTemplate,
                    Title = document.Title,
                    Locale = document.Locale,
                    ColorScheme = document.ColorScheme,
                    Content = JsonSerializer.Deserialize<CvContentDto>(document.ContentJson),
                    Status = document.Status,
                    CreatedAt = document.CreatedAt,
                    UpdatedAt = document.UpdatedAt,
                    Template = new CvTemplateDto
                    {
                        IdTemplate = document.Template.IdTemplate,
                        Slug = document.Template.Slug,
                        Name = document.Template.Name,
                        Engine = document.Template.Engine,
                        PreviewUrl = document.Template.PreviewUrl,
                        IsActive = document.Template.IsActive,
                        CreatedAt = document.Template.CreatedAt,
                        UpdatedAt = document.Template.UpdatedAt
                    }
                };

                byte[] fileBytes;
                string fileName;
                string fileUrl;

                if (exportDto.Format == CvExportFormat.Pdf)
                {
                    fileBytes = await _cvRenderService.RenderPdfAsync(documentDto);
                    fileName = $"{document.Title ?? "CV"}_{DateTime.Now:yyyyMMdd_HHmmss}.pdf";
                    fileUrl = await _cvRenderService.SavePdfToStorageAsync(fileBytes, fileName);
                }
                else
                {
                    var htmlContent = await _cvRenderService.RenderHtmlAsync(documentDto);
                    fileBytes = System.Text.Encoding.UTF8.GetBytes(htmlContent);
                    fileName = $"{document.Title ?? "CV"}_{DateTime.Now:yyyyMMdd_HHmmss}.html";
                    fileUrl = await _cvRenderService.SavePdfToStorageAsync(fileBytes, fileName);
                }

                var export = new CvExport
                {
                    IdExport = Guid.NewGuid().ToString(),
                    IdDocument = document.IdDocument,
                    Format = exportDto.Format,
                    FileUrl = fileUrl,
                    FileSizeKB = fileBytes.Length / 1024,
                    CreatedAt = DateTime.Now
                };

                _context.CvExports.Add(export);
                await _context.SaveChangesAsync();

                var exportResult = new CvExportDto
                {
                    IdExport = export.IdExport,
                    IdDocument = export.IdDocument,
                    Format = export.Format,
                    FileUrl = export.FileUrl,
                    FileSizeKB = export.FileSizeKB,
                    CreatedAt = export.CreatedAt
                };

                return Ok(exportResult);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exporting CV document {DocumentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/exports")]
        public async Task<ActionResult<IEnumerable<CvExportDto>>> GetDocumentExports(string id)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var document = await _context.CvDocuments
                    .Where(d => d.IdDocument == id && d.IdUser == userId)
                    .FirstOrDefaultAsync();

                if (document == null)
                {
                    return NotFound();
                }

                var exports = await _context.CvExports
                    .Where(e => e.IdDocument == id)
                    .OrderByDescending(e => e.CreatedAt)
                    .Select(e => new CvExportDto
                    {
                        IdExport = e.IdExport,
                        IdDocument = e.IdDocument,
                        Format = e.Format,
                        FileUrl = e.FileUrl,
                        FileSizeKB = e.FileSizeKB,
                        CreatedAt = e.CreatedAt
                    })
                    .ToListAsync();

                return Ok(exports);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving CV document exports {DocumentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
