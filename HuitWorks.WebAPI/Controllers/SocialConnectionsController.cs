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
    public class SocialConnectionsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public SocialConnectionsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpPost("request")]
        public async Task<IActionResult> SendRequest([FromBody] CreateConnectionRequestDto input)
        {
            if (input.FromUserId == input.ToUserId) return BadRequest("Không thể kết bạn với chính mình");

            var key1 = await _context.SocialConnections.FindAsync(input.FromUserId, input.ToUserId);
            var key2 = await _context.SocialConnections.FindAsync(input.ToUserId, input.FromUserId);
            if (key1 != null || key2 != null) return Conflict("Kết nối đã tồn tại hoặc đang chờ");

            var entity = new SocialConnection
            {
                IdUser1 = input.FromUserId,
                IdUser2 = input.ToUserId,
                Status = "pending",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.SocialConnections.Add(entity);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("accept")]
        public async Task<IActionResult> Accept([FromBody] CreateConnectionRequestDto input)
        {
            var entity = await _context.SocialConnections.FindAsync(input.ToUserId, input.FromUserId);
            if (entity == null) return NotFound("Không tìm thấy lời mời");
            entity.Status = "accepted";
            entity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("reject")]
        public async Task<IActionResult> Reject([FromBody] CreateConnectionRequestDto input)
        {
            var entity = await _context.SocialConnections.FindAsync(input.ToUserId, input.FromUserId);
            if (entity == null) return NotFound("Không tìm thấy lời mời");
            _context.SocialConnections.Remove(entity);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("cancel")]
        public async Task<IActionResult> Cancel([FromBody] CreateConnectionRequestDto input)
        {
            var entity = await _context.SocialConnections.FindAsync(input.FromUserId, input.ToUserId);
            if (entity == null) return NotFound("Không tìm thấy lời mời");
            _context.SocialConnections.Remove(entity);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("block")]
        public async Task<IActionResult> Block([FromBody] CreateConnectionRequestDto input)
        {
            var entity = await _context.SocialConnections.FindAsync(input.FromUserId, input.ToUserId) 
                         ?? await _context.SocialConnections.FindAsync(input.ToUserId, input.FromUserId);
            if (entity == null)
            {
                entity = new SocialConnection
                {
                    IdUser1 = input.FromUserId,
                    IdUser2 = input.ToUserId,
                    Status = "blocked",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.SocialConnections.Add(entity);
            }
            else
            {
                entity.Status = "blocked";
                entity.UpdatedAt = DateTime.UtcNow;
            }
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpDelete("unfriend")]
        public async Task<IActionResult> Unfriend([FromQuery] string userId1, [FromQuery] string userId2)
        {
            var entity = await _context.SocialConnections.FindAsync(userId1, userId2) 
                         ?? await _context.SocialConnections.FindAsync(userId2, userId1);
            if (entity == null) return NotFound();
            _context.SocialConnections.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        [HttpGet("requests/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetRequests(string userId)
        {
            var list = await _context.SocialConnections
                .Where(c => c.Status == "pending" && c.IdUser2 == userId)
                .Join(_context.Users, c => c.IdUser1, u => u.IdUser, (c, u) => new
                {
                    IdUser1 = c.IdUser1,
                    IdUser2 = c.IdUser2,
                    Status = c.Status,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    SenderName = u.UserName ?? u.Email,
                    SenderAvatar = u.AvatarUrl
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpGet("sent/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetSentRequests(string userId)
        {
            var list = await _context.SocialConnections
                .Where(c => c.Status == "pending" && c.IdUser1 == userId)
                .Join(_context.Users, c => c.IdUser2, u => u.IdUser, (c, u) => new
                {
                    IdUser1 = c.IdUser1,
                    IdUser2 = c.IdUser2,
                    Status = c.Status,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    ReceiverName = u.UserName ?? u.Email,
                    ReceiverAvatar = u.AvatarUrl
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpGet("friends/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetFriends(string userId)
        {
            var friends = await _context.SocialConnections
                .Where(c => c.Status == "accepted" && (c.IdUser1 == userId || c.IdUser2 == userId))
                .Join(_context.Users, c => c.IdUser1 == userId ? c.IdUser2 : c.IdUser1, u => u.IdUser, (c, u) => new
                {
                    Id = u.IdUser,
                    Name = u.UserName ?? u.Email,
                    Avatar = u.AvatarUrl,
                    Email = u.Email,
                    CreatedAt = c.CreatedAt,
                    LastActivity = DateTime.UtcNow // TODO: Add last activity tracking
                })
                .ToListAsync();
            return Ok(friends);
        }

        [HttpPost("accept-all")]
        public async Task<IActionResult> AcceptAllRequests([FromBody] AcceptAllRequestsDto input)
        {
            var requests = await _context.SocialConnections
                .Where(c => c.Status == "pending" && c.IdUser2 == input.UserId)
                .ToListAsync();

            foreach (var request in requests)
            {
                request.Status = "accepted";
                request.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("cancel-all")]
        public async Task<IActionResult> CancelAllSent([FromBody] CancelAllSentDto input)
        {
            var sent = await _context.SocialConnections
                .Where(c => c.Status == "pending" && c.IdUser1 == input.UserId)
                .ToListAsync();

            _context.SocialConnections.RemoveRange(sent);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpGet("status")]
        public async Task<IActionResult> GetFriendStatus([FromQuery] string currentUserId, [FromQuery] string targetUserId)
        {
            if (string.IsNullOrEmpty(currentUserId) || string.IsNullOrEmpty(targetUserId))
                return BadRequest("Missing user IDs");

            Console.WriteLine($"GetFriendStatus: '{currentUserId}' -> '{targetUserId}'");

            // Kiểm tra kết nối từ currentUserId -> targetUserId
            var connection1 = await _context.SocialConnections.FindAsync(currentUserId, targetUserId);
            // Kiểm tra kết nối từ targetUserId -> currentUserId
            var connection2 = await _context.SocialConnections.FindAsync(targetUserId, currentUserId);

            Console.WriteLine($"Connection1: {connection1?.IdUser1} -> {connection1?.IdUser2} ({connection1?.Status})");
            Console.WriteLine($"Connection2: {connection2?.IdUser1} -> {connection2?.IdUser2} ({connection2?.Status})");
            
            // Thử tìm kiếm bằng LINQ để debug
            var allConnections = await _context.SocialConnections.ToListAsync();
            Console.WriteLine($"Total connections in DB: {allConnections.Count}");
            var matchingConnections = allConnections.Where(c => 
                (c.IdUser1 == currentUserId && c.IdUser2 == targetUserId) ||
                (c.IdUser1 == targetUserId && c.IdUser2 == currentUserId)
            ).ToList();
            Console.WriteLine($"Matching connections found: {matchingConnections.Count}");
            foreach(var conn in matchingConnections) {
                Console.WriteLine($"  - {conn.IdUser1} -> {conn.IdUser2} ({conn.Status})");
            }

            // Sử dụng LINQ thay vì FindAsync nếu có vấn đề
            var connection = connection1 ?? connection2 ?? matchingConnections.FirstOrDefault();
            if (connection == null)
            {
                Console.WriteLine("No connection found, returning 'none'");
                return Ok("none"); // Không có kết nối
            }

            // Xác định trạng thái dựa trên người gửi
            if (connection.IdUser1 == currentUserId)
            {
                // Current user là người gửi
                switch (connection.Status)
                {
                    case "pending":
                        return Ok("pending_sent");
                    case "accepted":
                        return Ok("accepted");
                    case "blocked":
                        return Ok("blocked");
                }
            }
            else
            {
                // Current user là người nhận
                switch (connection.Status)
                {
                    case "pending":
                        return Ok("pending_received");
                    case "accepted":
                        return Ok("accepted");
                    case "blocked":
                        return Ok("blocked");
                }
            }

            return Ok("none");
        }
    }
}


