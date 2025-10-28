// Controllers/NotificationController.cs
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
    public class NotificationController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public NotificationController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/notification
        [HttpGet]
        public async Task<ActionResult<IEnumerable<NotificationDto>>> GetAll()
        {
            var list = await _context.Notifications
                .Select(n => new NotificationDto
                {
                    IdNotification = n.IdNotification,
                    IdUser = n.IdUser,
                    Title = n.Title,
                    Type = n.Type,
                    DateTime = n.DateTime,
                    Status = n.Status,
                    ActionUrl = n.ActionUrl,
                    CreatedAt = n.CreatedAt,
                    IsRead = n.IsRead
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET: api/notification/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<NotificationDto>> GetById(string id)
        {
            var dto = await _context.Notifications
                .Where(n => n.IdUser == id)
                .Select(n => new NotificationDto
                {
                    IdNotification = n.IdNotification,
                    IdUser = n.IdUser,
                    Title = n.Title,
                    Type = n.Type,
                    DateTime = n.DateTime,
                    Status = n.Status,
                    ActionUrl = n.ActionUrl,
                    CreatedAt = n.CreatedAt,
                    IsRead = n.IsRead
                })
                .ToListAsync();

            if (dto == null)
                return NotFound(new { message = "Không tìm thấy thông báo." });

            return Ok(dto);
        }

        // POST: api/notification
        [HttpPost]
        public async Task<ActionResult<NotificationDto>> Create([FromBody] CreateNotificationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // (Tùy chọn) kiểm tra idUser tồn tại trong bảng Users
            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new Notification
            {
                IdNotification = System.Guid.NewGuid().ToString(),
                IdUser = dto.IdUser,
                Title = dto.Title,
                Type = dto.Type,
                DateTime = dto.DateTime,
                Status = dto.Status,
                ActionUrl = dto.ActionUrl,
                CreatedAt = System.DateTime.UtcNow,
                IsRead = dto.IsRead
            };

            _context.Notifications.Add(entity);
            await _context.SaveChangesAsync();

            var result = new NotificationDto
            {
                IdNotification = entity.IdNotification,
                IdUser = entity.IdUser,
                Title = entity.Title,
                Type = entity.Type,
                DateTime = entity.DateTime,
                Status = entity.Status,
                ActionUrl = entity.ActionUrl,
                CreatedAt = entity.CreatedAt,
                IsRead = entity.IsRead
            };

            return CreatedAtAction(nameof(GetById), new { id = result.IdNotification }, result);
        }

        // PUT: api/notification/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateNotificationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.Notifications.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy thông báo." });

            entity.Title = dto.Title ?? entity.Title;
            entity.Type = dto.Type ?? entity.Type;
            entity.DateTime = dto.DateTime ?? entity.DateTime;
            entity.Status = dto.Status ?? entity.Status;
            entity.ActionUrl = dto.ActionUrl ?? entity.ActionUrl;
            entity.IsRead = dto.IsRead ?? entity.IsRead;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/notification/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.Notifications.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy thông báo." });

            _context.Notifications.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
