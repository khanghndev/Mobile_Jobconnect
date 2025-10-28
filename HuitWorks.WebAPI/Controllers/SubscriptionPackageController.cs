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
    public class SubscriptionPackageController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SubscriptionPackageController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SubscriptionPackage
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SubscriptionPackageDto>>> GetAll()
        {
            var packages = await _context.SubscriptionPackages
                .Select(sp => new SubscriptionPackageDto
                {
                    IdPackage = sp.IdPackage,
                    PackageName = sp.PackageName,
                    Price = sp.Price,
                    DurationDays = sp.DurationDays,
                    Description = sp.Description,
                    JobPostLimit = sp.JobPostLimit,
                    CvViewLimit = sp.CvViewLimit,
                    CreatedAt = sp.CreatedAt,
                    IsActive = sp.IsActive
                })
                .ToListAsync();

            return Ok(packages);
        }

        // GET: api/SubscriptionPackage/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<SubscriptionPackageDto>> GetById(string id)
        {
            var sp = await _context.SubscriptionPackages.FindAsync(id);
            if (sp == null)
                return NotFound(new { message = "SubscriptionPackage not found." });

            var dto = new SubscriptionPackageDto
            {
                IdPackage = sp.IdPackage,
                PackageName = sp.PackageName,
                Price = sp.Price,
                DurationDays = sp.DurationDays,
                Description = sp.Description,
                JobPostLimit = sp.JobPostLimit,
                CvViewLimit = sp.CvViewLimit,
                CreatedAt = sp.CreatedAt,
                IsActive = sp.IsActive
            };

            return Ok(dto);
        }

        // POST: api/SubscriptionPackage
        [HttpPost]
        public async Task<ActionResult<SubscriptionPackageDto>> Create([FromBody] CreateSubscriptionPackageDto dto)
        {
            var newId = Guid.NewGuid().ToString();

            if (await _context.SubscriptionPackages.AnyAsync(x => x.IdPackage == newId))
                return Conflict(new { message = "GUID collision, please try again." });

            var nowUtc = DateTime.UtcNow;
            var entity = new SubscriptionPackage
            {
                IdPackage = newId,
                PackageName = dto.PackageName,
                Price = dto.Price,
                DurationDays = dto.DurationDays,
                Description = dto.Description,
                JobPostLimit = dto.JobPostLimit,
                CvViewLimit = dto.CvViewLimit,
                CreatedAt = nowUtc,
                IsActive = true
            };

            _context.SubscriptionPackages.Add(entity);
            await _context.SaveChangesAsync();

            var createdDto = new SubscriptionPackageDto
            {
                IdPackage = entity.IdPackage,
                PackageName = entity.PackageName,
                Price = entity.Price,
                DurationDays = entity.DurationDays,
                Description = entity.Description,
                JobPostLimit = entity.JobPostLimit,
                CvViewLimit = entity.CvViewLimit,
                CreatedAt = entity.CreatedAt,
                IsActive = entity.IsActive
            };

            return CreatedAtAction(nameof(GetById), new { id = createdDto.IdPackage }, createdDto);
        }

        // PUT: api/SubscriptionPackage/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateSubscriptionPackageDto dto)
        {
            var entity = await _context.SubscriptionPackages.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "SubscriptionPackage not found." });

            entity.PackageName = dto.PackageName ?? entity.PackageName;
            entity.Price = dto.Price ?? entity.Price;
            entity.DurationDays = dto.DurationDays ?? entity.DurationDays;
            entity.Description = dto.Description ?? entity.Description;
            entity.JobPostLimit = dto.JobPostLimit ?? entity.JobPostLimit;
            entity.CvViewLimit = dto.CvViewLimit ?? entity.CvViewLimit;
            entity.IsActive = dto.IsActive ?? entity.IsActive;

            _context.SubscriptionPackages.Update(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/SubscriptionPackage/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.SubscriptionPackages.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "SubscriptionPackage not found." });

            bool hasTransactions = await _context.JobTransactions.AnyAsync(t => t.IdPackage == id);
            if (hasTransactions)
                return BadRequest(new { message = "Cannot delete SubscriptionPackage because it is referenced by one or more JobTransaction." });

            _context.SubscriptionPackages.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
