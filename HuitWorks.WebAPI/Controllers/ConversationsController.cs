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
    public class ConversationsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public ConversationsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<ActionResult<ConversationDto>> Create([FromBody] CreateConversationDto input)
        {
            if (input.MemberIds == null || input.MemberIds.Count < 2)
                return BadRequest("Cần ít nhất 2 thành viên");

            var conv = new Conversation
            {
                IdConversation = Guid.NewGuid().ToString("N"),
                CreatedAt = DateTime.UtcNow
            };
            _context.Conversations.Add(conv);

            foreach (var uid in input.MemberIds.Distinct())
            {
                _context.ConversationMembers.Add(new ConversationMember
                {
                    IdConversation = conv.IdConversation,
                    IdUser = uid,
                    JoinedAt = DateTime.UtcNow
                });
            }

            await _context.SaveChangesAsync();

            return Ok(new ConversationDto
            {
                IdConversation = conv.IdConversation,
                CreatedAt = conv.CreatedAt,
                Members = input.MemberIds.Distinct().ToList()
            });
        }

        [HttpPost("{conversationId}/members")]
        public async Task<IActionResult> AddMember(string conversationId, [FromBody] string userId)
        {
            var exists = await _context.ConversationMembers.FindAsync(conversationId, userId);
            if (exists != null) return NoContent();
            _context.ConversationMembers.Add(new ConversationMember
            {
                IdConversation = conversationId,
                IdUser = userId,
                JoinedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpDelete("{conversationId}/members/{userId}")]
        public async Task<IActionResult> RemoveMember(string conversationId, string userId)
        {
            var member = await _context.ConversationMembers.FindAsync(conversationId, userId);
            if (member == null) return NotFound();
            _context.ConversationMembers.Remove(member);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("by-user/{userId}")]
        public async Task<ActionResult<IEnumerable<ConversationDto>>> GetByUser(string userId)
        {
            var convIds = await _context.ConversationMembers
                .Where(cm => cm.IdUser == userId)
                .Select(cm => cm.IdConversation)
                .ToListAsync();

            var result = await _context.Conversations
                .Where(c => convIds.Contains(c.IdConversation))
                .Select(c => new ConversationDto
                {
                    IdConversation = c.IdConversation,
                    CreatedAt = c.CreatedAt,
                    Members = _context.ConversationMembers
                        .Where(cm => cm.IdConversation == c.IdConversation)
                        .Select(cm => cm.IdUser)
                        .ToList()
                })
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return Ok(result);
        }

        [HttpGet("{conversationId}/messages")]
        public async Task<ActionResult<IEnumerable<MessageDto>>> GetMessages(string conversationId, [FromQuery] int limit = 50, [FromQuery] int offset = 0)
        {
            var msgs = await _context.Messages
                .Where(m => m.IdConversation == conversationId)
                .OrderByDescending(m => m.SentAt)
                .Skip(offset)
                .Take(limit)
                .Select(m => new MessageDto
                {
                    IdMessage = m.IdMessage,
                    IdConversation = m.IdConversation,
                    IdSender = m.IdSender,
                    Content = m.Content,
                    MessageType = m.MessageType,
                    SentAt = m.SentAt,
                    IsRead = m.IsRead
                })
                .ToListAsync();
            msgs.Reverse();
            return Ok(msgs);
        }
    }
}


