using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RecruiterInfoController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public RecruiterInfoController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/recruiterinfo
        [HttpGet]
        public async Task<ActionResult<IEnumerable<RecruiterInfoDto>>> GetAll()
        {
            var list = await _context.RecruiterInfo
                .Select(r => new RecruiterInfoDto
                {
                    IdUser = r.IdUser,
                    Title = r.Title,
                    IdCompany = r.IdCompany,
                    Department = r.Department,
                    Description = r.Description
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/recruiterinfo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<RecruiterInfoDto>> GetById(string id)
        {
            var dto = await _context.RecruiterInfo
                .Where(r => r.IdUser == id)
                .Select(r => new RecruiterInfoDto
                {
                    IdUser = r.IdUser,
                    Title = r.Title,
                    IdCompany = r.IdCompany,
                    Department = r.Department,
                    Description = r.Description
                })
                .FirstOrDefaultAsync();

            if (dto == null)
                return NotFound(new { message = "Không tìm thấy thông tin tuyển dụng." });

            return Ok(dto);
        }

        // POST: api/recruiterinfo
        [HttpPost]
        public async Task<ActionResult<RecruiterInfoDto>> Create([FromBody] CreateRecruiterInfoDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra user tồn tại
            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new RecruiterInfo
            {
                IdUser = dto.IdUser,
                Title = dto.Title,
                IdCompany = dto.IdCompany,
                Department = dto.Department,
                Description = dto.Description
            };

            _context.RecruiterInfo.Add(entity);
            await _context.SaveChangesAsync();

            var result = new RecruiterInfoDto
            {
                IdUser = entity.IdUser,
                Title = entity.Title,
                IdCompany = entity.IdCompany,
                Department = entity.Department,
                Description = entity.Description
            };

            return CreatedAtAction(nameof(GetById), new { id = result.IdUser }, result);
        }

        // PUT: api/recruiterinfo/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateRecruiterInfoDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.RecruiterInfo.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy thông tin tuyển dụng." });

            entity.Title = dto.Title ?? entity.Title;
            entity.IdCompany = dto.IdCompany ?? entity.IdCompany;
            entity.Department = dto.Department ?? entity.Department;
            entity.Description = dto.Description ?? entity.Description;

            _context.RecruiterInfo.Update(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/recruiterinfo/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.RecruiterInfo.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy thông tin tuyển dụng." });

            _context.RecruiterInfo.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
