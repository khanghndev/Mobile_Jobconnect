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
    public class SocialMessagesController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public SocialMessagesController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpPost("send")]
        public async Task<ActionResult<SocialMessageDto>> Send([FromBody] SendMessageDto input)
        {
            var entity = new SocialMessage
            {
                IdMessage = Guid.NewGuid().ToString("N"),
                SenderId = input.SenderId,
                ReceiverId = input.ReceiverId,
                Content = input.Content,
                IsRead = 0,
                SentAt = DateTime.UtcNow
            };
            _context.SocialMessages.Add(entity);
            await _context.SaveChangesAsync();
            return Ok(new SocialMessageDto
            {
                IdMessage = entity.IdMessage,
                SenderId = entity.SenderId,
                ReceiverId = entity.ReceiverId,
                Content = entity.Content,
                IsRead = entity.IsRead,
                SentAt = entity.SentAt
            });
        }

        [HttpGet("thread")]
        public async Task<ActionResult<IEnumerable<SocialMessageDto>>> Thread([FromQuery] string userA, [FromQuery] string userB)
        {
            var list = await _context.SocialMessages
                .Where(m => (m.SenderId == userA && m.ReceiverId == userB) || (m.SenderId == userB && m.ReceiverId == userA))
                .OrderBy(m => m.SentAt)
                .Select(m => new SocialMessageDto
                {
                    IdMessage = m.IdMessage,
                    SenderId = m.SenderId,
                    ReceiverId = m.ReceiverId,
                    Content = m.Content,
                    IsRead = m.IsRead,
                    SentAt = m.SentAt
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpPost("mark-read")]
        public async Task<IActionResult> MarkRead([FromQuery] string userA, [FromQuery] string userB)
        {
            var msgs = await _context.SocialMessages
                .Where(m => m.SenderId == userB && m.ReceiverId == userA && m.IsRead == 0)
                .ToListAsync();
            foreach (var m in msgs)
            {
                m.IsRead = 1;
            }
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("unread-count/{userId}")]
        public async Task<ActionResult<int>> UnreadCount(string userId)
        {
            var count = await _context.SocialMessages.CountAsync(m => m.ReceiverId == userId && m.IsRead == 0);
            return Ok(count);
        }
    }
}


