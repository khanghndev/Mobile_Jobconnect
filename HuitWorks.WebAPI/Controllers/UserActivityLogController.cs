// HuitWorks.WebAPI/Controllers/UserActivityLogController.cs
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
    public class UserActivityLogController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public UserActivityLogController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/UserActivityLog
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserActivityLogDto>>> GetAllLogs()
        {
            var logs = await _context.UserActivityLogs
                .OrderByDescending(l => l.CreatedAt)
                .Select(l => new UserActivityLogDto
                {
                    IdLog = l.IdLog,
                    IdUser = l.IdUser,
                    ActionType = l.ActionType,
                    Description = l.Description,
                    EntityName = l.EntityName,
                    EntityId = l.EntityId,
                    IpAddress = l.IpAddress,
                    UserAgent = l.UserAgent,
                    CreatedAt = l.CreatedAt
                })
                .ToListAsync();

            return Ok(logs);
        }

        // GET: api/UserActivityLog/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<UserActivityLogDto>> GetLogById(string id)
        {
            var log = await _context.UserActivityLogs.FindAsync(id);
            if (log == null)
                return NotFound(new { message = "Không tìm thấy bản ghi lịch sử hoạt động." });

            var dto = new UserActivityLogDto
            {
                IdLog = log.IdLog,
                IdUser = log.IdUser,
                ActionType = log.ActionType,
                Description = log.Description,
                EntityName = log.EntityName,
                EntityId = log.EntityId,
                IpAddress = log.IpAddress,
                UserAgent = log.UserAgent,
                CreatedAt = log.CreatedAt
            };

            return Ok(dto);
        }

        // POST: api/UserActivityLog
        [HttpPost]
        public async Task<ActionResult<UserActivityLogDto>> CreateLog([FromBody] CreateUserActivityLogDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userExists = await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser);
            if (!userExists)
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new UserActivityLog
            {
                IdLog = Guid.NewGuid().ToString(),
                IdUser = dto.IdUser,
                ActionType = dto.ActionType,
                Description = dto.Description,
                EntityName = dto.EntityName,
                EntityId = dto.EntityId,
                IpAddress = dto.IpAddress,
                UserAgent = dto.UserAgent,
            };

            _context.UserActivityLogs.Add(entity);
            await _context.SaveChangesAsync();

            var resultDto = new UserActivityLogDto
            {
                IdLog = entity.IdLog,
                IdUser = entity.IdUser,
                ActionType = entity.ActionType,
                Description = entity.Description,
                EntityName = entity.EntityName,
                EntityId = entity.EntityId,
                IpAddress = entity.IpAddress,
                UserAgent = entity.UserAgent,
                CreatedAt = entity.CreatedAt
            };

            return CreatedAtAction(nameof(GetLogById), new { id = entity.IdLog }, resultDto);
        }

        // DELETE: api/UserActivityLog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteLog(string id)
        {
            var entity = await _context.UserActivityLogs.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy bản ghi lịch sử hoạt động." });

            _context.UserActivityLogs.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
