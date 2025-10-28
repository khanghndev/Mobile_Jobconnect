using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CvShareController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly ILogger<CvShareController> _logger;

        public CvShareController(JobConnectDbContext context, ILogger<CvShareController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost]
        public async Task<ActionResult<CvShareLinkDto>> CreateShareLink([FromBody] CreateCvShareLinkDto createDto)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var document = await _context.CvDocuments
                    .Where(d => d.IdDocument == createDto.IdDocument && d.IdUser == userId)
                    .FirstOrDefaultAsync();

                if (document == null)
                {
                    return NotFound();
                }

                var token = GenerateSecureToken();
                var shareLink = new CvShareLink
                {
                    IdShare = Guid.NewGuid().ToString(),
                    IdDocument = createDto.IdDocument,
                    Token = token,
                    AccessLevel = createDto.AccessLevel,
                    ExpireAt = createDto.ExpireAt,
                    IsActive = true,
                    CreatedAt = DateTime.Now
                };

                _context.CvShareLinks.Add(shareLink);
                await _context.SaveChangesAsync();

                var shareLinkDto = new CvShareLinkDto
                {
                    IdShare = shareLink.IdShare,
                    IdDocument = shareLink.IdDocument,
                    Token = shareLink.Token,
                    AccessLevel = shareLink.AccessLevel,
                    ExpireAt = shareLink.ExpireAt,
                    IsActive = shareLink.IsActive,
                    CreatedAt = shareLink.CreatedAt,
                    ShareUrl = $"{Request.Scheme}://{Request.Host}/api/cv/share/{shareLink.Token}"
                };

                return Ok(shareLinkDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating CV share link");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{token}")]
        [AllowAnonymous]
        public async Task<ActionResult<CvDocumentDto>> GetSharedDocument(string token)
        {
            try
            {
                var shareLink = await _context.CvShareLinks
                    .Where(sl => sl.Token == token && sl.IsActive)
                    .Include(sl => sl.Document)
                    .ThenInclude(d => d.Template)
                    .FirstOrDefaultAsync();

                if (shareLink == null)
                {
                    return NotFound("Share link not found or expired");
                }

                if (shareLink.ExpireAt.HasValue && shareLink.ExpireAt < DateTime.Now)
                {
                    return BadRequest("Share link has expired");
                }

                var document = shareLink.Document;
                var documentDto = new CvDocumentDto
                {
                    IdDocument = document.IdDocument,
                    IdUser = document.IdUser,
                    IdTemplate = document.IdTemplate,
                    Title = document.Title,
                    Locale = document.Locale,
                    ColorScheme = document.ColorScheme,
                    Content = System.Text.Json.JsonSerializer.Deserialize<CvContentDto>(document.ContentJson),
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

                return Ok(documentDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving shared CV document with token {Token}", token);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("my-shares")]
        public async Task<ActionResult<IEnumerable<CvShareLinkDto>>> GetMyShareLinks()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var shareLinks = await _context.CvShareLinks
                    .Where(sl => sl.Document.IdUser == userId)
                    .OrderByDescending(sl => sl.CreatedAt)
                    .Select(sl => new CvShareLinkDto
                    {
                        IdShare = sl.IdShare,
                        IdDocument = sl.IdDocument,
                        Token = sl.Token,
                        AccessLevel = sl.AccessLevel,
                        ExpireAt = sl.ExpireAt,
                        IsActive = sl.IsActive,
                        CreatedAt = sl.CreatedAt,
                        ShareUrl = $"{Request.Scheme}://{Request.Host}/api/cv/share/{sl.Token}"
                    })
                    .ToListAsync();

                return Ok(shareLinks);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving user's CV share links");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeactivateShareLink(string id)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized();
                }

                var shareLink = await _context.CvShareLinks
                    .Where(sl => sl.IdShare == id && sl.Document.IdUser == userId)
                    .FirstOrDefaultAsync();

                if (shareLink == null)
                {
                    return NotFound();
                }

                shareLink.IsActive = false;
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deactivating CV share link {ShareLinkId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        private string GenerateSecureToken()
        {
            using var rng = RandomNumberGenerator.Create();
            var bytes = new byte[32];
            rng.GetBytes(bytes);
            return Convert.ToBase64String(bytes).Replace("+", "-").Replace("/", "_").Replace("=", "");
        }
    }
}
