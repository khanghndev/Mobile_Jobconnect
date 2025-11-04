// Controllers/NotificationController.cs
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.Services;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly IPushNotificationService _pushNotificationService;

        public NotificationController(JobConnectDbContext context, IPushNotificationService pushNotificationService)
        {
            _context = context;
            _pushNotificationService = pushNotificationService;
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

        // GET: api/notification/user/{idUser}
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<NotificationDto>>> GetByUserId(string idUser)
        {
            var notifications = await _context.Notifications
                .Where(n => n.IdUser == idUser)
                .OrderByDescending(n => n.DateTime)
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

            if (notifications == null || notifications.Count == 0)
                return NotFound(new { message = "Người dùng này không có thông báo nào." });

            return Ok(notifications);
        }

        // PUT: api/notification/update-device
        [HttpPut("update-device")]
        public async Task<IActionResult> UpdateDevice([FromBody] UpdateDeviceDto dto)
        {
            if (string.IsNullOrEmpty(dto.IdUser) || string.IsNullOrEmpty(dto.NewToken))
                return BadRequest(new { message = "Thiếu thông tin người dùng hoặc token mới." });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.IdUser == dto.IdUser);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng." });

            // Tìm token cũ nếu có
            DeviceToken deviceToken = null;

            if (!string.IsNullOrEmpty(dto.OldToken))
            {
                deviceToken = await _context.DeviceTokens
                    .FirstOrDefaultAsync(t => t.IdUser == dto.IdUser && t.Token == dto.OldToken);
            }

            // Nếu không tìm thấy token cũ thì tạo mới
            if (deviceToken == null)
            {
                deviceToken = new DeviceToken
                {
                    Id = Guid.NewGuid().ToString(),
                    IdUser = dto.IdUser,
                    Token = dto.NewToken,
                    CreatedAt = DateTime.UtcNow
                };
                _context.DeviceTokens.Add(deviceToken);
            }
            else
            {
                // Cập nhật token cũ thành token mới
                deviceToken.Token = dto.NewToken;
                deviceToken.CreatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật thiết bị thành công." });
        }

        /// <summary>
        /// Gửi push notification đến một user cụ thể
        /// </summary>
        [HttpPost("send-push/{userId}")]
        public async Task<IActionResult> SendPushNotification(string userId, [FromBody] SendPushNotificationDto dto)
        {
            if (string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(dto.Title) || string.IsNullOrWhiteSpace(dto.Body))
                return BadRequest(new { message = "Thiếu thông tin bắt buộc" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.IdUser == userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            var data = new Dictionary<string, string>();
            if (!string.IsNullOrWhiteSpace(dto.Type))
                data["type"] = dto.Type;
            if (!string.IsNullOrWhiteSpace(dto.ActionUrl))
                data["actionUrl"] = dto.ActionUrl;
            if (!string.IsNullOrWhiteSpace(dto.NotificationId))
                data["notificationId"] = dto.NotificationId;

            var result = await _pushNotificationService.SendPushNotificationToUserAsync(userId, dto.Title, dto.Body, data);

            if (result)
                return Ok(new { message = "Đã gửi push notification thành công" });
            else
                return StatusCode(500, new { message = "Gửi push notification thất bại" });
        }

        /// <summary>
        /// Gửi push notification đến nhiều users
        /// </summary>
        [HttpPost("send-push-multiple")]
        public async Task<IActionResult> SendPushNotificationToMultiple([FromBody] SendPushNotificationMultipleDto dto)
        {
            if (dto.UserIds == null || !dto.UserIds.Any() || string.IsNullOrWhiteSpace(dto.Title) || string.IsNullOrWhiteSpace(dto.Body))
                return BadRequest(new { message = "Thiếu thông tin bắt buộc" });

            var data = new Dictionary<string, string>();
            if (!string.IsNullOrWhiteSpace(dto.Type))
                data["type"] = dto.Type;
            if (!string.IsNullOrWhiteSpace(dto.ActionUrl))
                data["actionUrl"] = dto.ActionUrl;

            var result = await _pushNotificationService.SendPushNotificationToMultipleUsersAsync(dto.UserIds, dto.Title, dto.Body, data);

            if (result)
                return Ok(new { message = "Đã gửi push notification thành công" });
            else
                return StatusCode(500, new { message = "Gửi push notification thất bại" });
        }

        /// <summary>
        /// Tạo notification và gửi push notification
        /// </summary>
        [HttpPost("create-and-send")]
        public async Task<ActionResult<NotificationDto>> CreateAndSend([FromBody] CreateNotificationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new Notification
            {
                IdNotification = System.Guid.NewGuid().ToString(),
                IdUser = dto.IdUser,
                Title = dto.Title,
                Type = dto.Type,
                DateTime = dto.DateTime,
                Status = "Đã gửi",
                ActionUrl = dto.ActionUrl,
                CreatedAt = System.DateTime.UtcNow,
                IsRead = dto.IsRead
            };

            _context.Notifications.Add(entity);
            await _context.SaveChangesAsync();

            // Gửi push notification
            var pushData = new Dictionary<string, string>
            {
                ["type"] = dto.Type,
                ["notificationId"] = entity.IdNotification
            };
            if (!string.IsNullOrWhiteSpace(dto.ActionUrl))
                pushData["actionUrl"] = dto.ActionUrl;

            await _pushNotificationService.SendPushNotificationToUserAsync(dto.IdUser, dto.Title, dto.Title, pushData);

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


    }
}
