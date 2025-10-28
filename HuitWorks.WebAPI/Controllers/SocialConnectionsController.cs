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

        [HttpGet("friends/{userId}")]
        public async Task<ActionResult<IEnumerable<string>>> GetFriends(string userId)
        {
            var friends = await _context.SocialConnections
                .Where(c => c.Status == "accepted" && (c.IdUser1 == userId || c.IdUser2 == userId))
                .Select(c => c.IdUser1 == userId ? c.IdUser2 : c.IdUser1)
                .ToListAsync();
            return Ok(friends);
        }

        [HttpGet("requests/{userId}")]
        public async Task<ActionResult<IEnumerable<SocialConnectionDto>>> GetRequests(string userId)
        {
            var list = await _context.SocialConnections
                .Where(c => c.Status == "pending" && c.IdUser2 == userId)
                .Select(c => new SocialConnectionDto
                {
                    IdUser1 = c.IdUser1,
                    IdUser2 = c.IdUser2,
                    Status = c.Status,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();
            return Ok(list);
        }
    }
}


