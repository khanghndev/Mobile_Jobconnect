using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NewsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public NewsController(JobConnectDbContext context) => _context = context;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<NewsDto>>> GetAll()
        {
            var list = await _context.News
                .OrderByDescending(x => x.PublishDate)
                .Select(n => new NewsDto
                {
                    IdNews = n.IdNews,
                    Title = n.Title,
                    Content = n.Content,
                    Summary = n.Summary,
                    ImageUrl = n.ImageUrl,
                    PublishDate = n.PublishDate,
                    Author = n.Author,
                    IsPublished = n.IsPublished,
                    CategoryName = n.CategoryName,
                    TargetAudience = n.TargetAudience
                })
                .ToListAsync();

            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NewsDto>> GetById(int id)
        {
            var dto = await _context.News
                .Where(n => n.IdNews == id)
                .Select(n => new NewsDto
                {
                    IdNews = n.IdNews,
                    Title = n.Title,
                    Content = n.Content,
                    Summary = n.Summary,
                    ImageUrl = n.ImageUrl,
                    PublishDate = n.PublishDate,
                    Author = n.Author,
                    IsPublished = n.IsPublished,
                    CategoryName = n.CategoryName,
                    TargetAudience = n.TargetAudience
                })
                .FirstOrDefaultAsync();

            return dto == null ? NotFound() : Ok(dto);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateNewsDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = new News
            {
                Title = dto.Title,
                Content = dto.Content,
                Summary = dto.Summary,
                ImageUrl = dto.ImageUrl,
                PublishDate = dto.PublishDate,
                Author = dto.Author,
                IsPublished = dto.IsPublished,
                CategoryName = dto.CategoryName,
                TargetAudience = dto.TargetAudience
            };

            _context.News.Add(entity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = entity.IdNews }, entity);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateNewsDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.News.FindAsync(id);
            if (entity == null)
                return NotFound();

            entity.Title = dto.Title;
            entity.Content = dto.Content;
            entity.Summary = dto.Summary;
            entity.ImageUrl = dto.ImageUrl;
            entity.PublishDate = dto.PublishDate;
            entity.Author = dto.Author;
            entity.IsPublished = dto.IsPublished;
            entity.CategoryName = dto.CategoryName;
            entity.TargetAudience = dto.TargetAudience;

            _context.News.Update(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _context.News.FindAsync(id);
            if (entity == null) return NotFound();

            _context.News.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
