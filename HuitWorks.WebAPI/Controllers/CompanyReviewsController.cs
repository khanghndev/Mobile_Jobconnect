using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;
using System;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CompanyReviewsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public CompanyReviewsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpGet("by-company/{companyId}")]
        public async Task<ActionResult<IEnumerable<CompanyReviewDto>>> ByCompany(string companyId)
        {
            var list = await _context.CompanyReviews
                .Where(r => r.IdCompany == companyId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new CompanyReviewDto
                {
                    IdReview = r.IdReview,
                    IdCompany = r.IdCompany,
                    IdUser = r.IdUser,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<ActionResult<CompanyReviewDto>> Create([FromBody] CreateCompanyReviewDto input)
        {
            if (input.Rating < 1 || input.Rating > 5) return BadRequest("Rating 1-5");
            var entity = new CompanyReview
            {
                IdReview = Guid.NewGuid().ToString("N"),
                IdCompany = input.IdCompany,
                IdUser = input.IdUser,
                Rating = input.Rating,
                Comment = input.Comment,
                CreatedAt = DateTime.UtcNow
            };
            _context.CompanyReviews.Add(entity);
            await _context.SaveChangesAsync();
            return Ok(new CompanyReviewDto
            {
                IdReview = entity.IdReview,
                IdCompany = entity.IdCompany,
                IdUser = entity.IdUser,
                Rating = entity.Rating,
                Comment = entity.Comment,
                CreatedAt = entity.CreatedAt
            });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.CompanyReviews.FindAsync(id);
            if (entity == null) return NotFound();
            _context.CompanyReviews.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}


