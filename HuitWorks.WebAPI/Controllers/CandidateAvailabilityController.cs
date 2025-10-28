using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CandidateAvailabilityController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public CandidateAvailabilityController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/candidateavailability
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CandidateAvailabilityDto>>> GetCandidateAvailability()
        {
            var availability = await _context.CandidateAvailability
                .Select(a => new CandidateAvailabilityDto
                {
                    IdAvailability = a.IdAvailability,
                    IdUser = a.IdUser,
                    AvailableDay = a.AvailableDay,
                    StartTime = a.StartTime,
                    EndTime = a.EndTime
                })
                .ToListAsync();

            return Ok(availability);
        }

        // GET: api/candidateavailability/user/{idUser}
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<CandidateAvailabilityDto>>> GetCandidateAvailabilityByUser(string idUser)
        {
            var availability = await _context.CandidateAvailability
                .Where(a => a.IdUser == idUser)
                .Select(a => new CandidateAvailabilityDto
                {
                    IdAvailability = a.IdAvailability,
                    IdUser = a.IdUser,
                    AvailableDay = a.AvailableDay,
                    StartTime = a.StartTime,
                    EndTime = a.EndTime
                })
                .ToListAsync();

            return Ok(availability);
        }

        // GET: api/candidateavailability/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<CandidateAvailabilityDto>> GetCandidateAvailabilityById(string id)
        {
            var availability = await _context.CandidateAvailability
                .Where(a => a.IdAvailability == id)
                .Select(a => new CandidateAvailabilityDto
                {
                    IdAvailability = a.IdAvailability,
                    IdUser = a.IdUser,
                    AvailableDay = a.AvailableDay,
                    StartTime = a.StartTime,
                    EndTime = a.EndTime
                })
                .FirstOrDefaultAsync();

            if (availability == null)
            {
                return NotFound("Không tìm thấy lịch rảnh");
            }

            return Ok(availability);
        }

        // POST: api/candidateavailability
        [HttpPost]
        public async Task<ActionResult<CandidateAvailabilityDto>> CreateCandidateAvailability(CreateCandidateAvailabilityDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra user có tồn tại không
            var userExists = await _context.Users.AnyAsync(u => u.IdUser == createDto.IdUser);
            if (!userExists)
            {
                return BadRequest("Người dùng không tồn tại");
            }

            // Kiểm tra thời gian hợp lệ
            if (createDto.StartTime >= createDto.EndTime)
            {
                return BadRequest("Thời gian bắt đầu phải nhỏ hơn thời gian kết thúc");
            }

            var availability = new CandidateAvailability
            {
                IdAvailability = Guid.NewGuid().ToString(),
                IdUser = createDto.IdUser,
                AvailableDay = createDto.AvailableDay,
                StartTime = createDto.StartTime,
                EndTime = createDto.EndTime
            };

            _context.CandidateAvailability.Add(availability);
            await _context.SaveChangesAsync();

            var availabilityDto = new CandidateAvailabilityDto
            {
                IdAvailability = availability.IdAvailability,
                IdUser = availability.IdUser,
                AvailableDay = availability.AvailableDay,
                StartTime = availability.StartTime,
                EndTime = availability.EndTime
            };

            return CreatedAtAction(nameof(GetCandidateAvailabilityById), new { id = availability.IdAvailability }, availabilityDto);
        }

        // PUT: api/candidateavailability/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCandidateAvailability(string id, UpdateCandidateAvailabilityDto updateDto)
        {
            if (id != updateDto.IdAvailability)
            {
                return BadRequest("ID không khớp");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra thời gian hợp lệ
            if (updateDto.StartTime >= updateDto.EndTime)
            {
                return BadRequest("Thời gian bắt đầu phải nhỏ hơn thời gian kết thúc");
            }

            var availability = await _context.CandidateAvailability.FindAsync(id);
            if (availability == null)
            {
                return NotFound("Không tìm thấy lịch rảnh");
            }

            availability.AvailableDay = updateDto.AvailableDay;
            availability.StartTime = updateDto.StartTime;
            availability.EndTime = updateDto.EndTime;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CandidateAvailabilityExists(id))
                {
                    return NotFound("Không tìm thấy lịch rảnh");
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/candidateavailability/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCandidateAvailability(string id)
        {
            var availability = await _context.CandidateAvailability.FindAsync(id);
            if (availability == null)
            {
                return NotFound("Không tìm thấy lịch rảnh");
            }

            _context.CandidateAvailability.Remove(availability);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CandidateAvailabilityExists(string id)
        {
            return _context.CandidateAvailability.Any(e => e.IdAvailability == id);
        }
    }
}
