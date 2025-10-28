using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;
using System;
using Microsoft.AspNetCore.SignalR;
using HuitWorks.WebAPI.Hubs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessagesController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        private readonly IHubContext<ChatHub> _hub;
        public MessagesController(JobConnectDbContext context, IHubContext<ChatHub> hub)
        {
            _context = context;
            _hub = hub;
        }

        [HttpPost]
        public async Task<ActionResult<MessageDto>> Send([FromBody] SendMessageRequestDto input)
        {
            var msg = new Message
            {
                IdMessage = Guid.NewGuid().ToString("N"),
                IdConversation = input.IdConversation,
                IdSender = input.IdSender,
                Content = input.Content,
                MessageType = input.MessageType,
                FileUrl = input.FileUrl,
                FileName = input.FileName,
                FileSize = input.FileSize,
                SentAt = DateTime.UtcNow,
                IsRead = 0
            };
            _context.Messages.Add(msg);
            await _context.SaveChangesAsync();

            // Broadcast tin nhắn mới tới group hội thoại
            await _hub.Clients.Group($"conv:{msg.IdConversation}").SendAsync("ReceiveMessage", new
            {
                idMessage = msg.IdMessage,
                idConversation = msg.IdConversation,
                idSender = msg.IdSender,
                content = msg.Content,
                messageType = msg.MessageType,
                fileUrl = msg.FileUrl,
                fileName = msg.FileName,
                fileSize = msg.FileSize,
                sentAt = msg.SentAt,
                isRead = msg.IsRead
            });

            // Gửi cập nhật badge unread cho các thành viên khác
            var members = await _context.ConversationMembers
                .Where(cm => cm.IdConversation == msg.IdConversation && cm.IdUser != msg.IdSender)
                .Select(cm => cm.IdUser)
                .ToListAsync();
            foreach (var memberId in members)
            {
                var convIds = await _context.ConversationMembers
                    .Where(cm => cm.IdUser == memberId)
                    .Select(cm => cm.IdConversation)
                    .ToListAsync();
                var unreadCount = await _context.Messages
                    .Where(m => convIds.Contains(m.IdConversation) && m.IsRead == 0 && m.IdSender != memberId)
                    .CountAsync();
                await _hub.Clients.Group($"user:{memberId}").SendAsync("UnreadCountUpdated", new { userId = memberId, count = unreadCount });
            }
            return Ok(new MessageDto
            {
                IdMessage = msg.IdMessage,
                IdConversation = msg.IdConversation,
                IdSender = msg.IdSender,
                Content = msg.Content,
                MessageType = msg.MessageType,
                FileUrl = msg.FileUrl,
                FileName = msg.FileName,
                FileSize = msg.FileSize,
                SentAt = msg.SentAt,
                IsRead = msg.IsRead
            });
        }

        [HttpGet("by-conversation/{conversationId}")]
        public async Task<ActionResult<IEnumerable<MessageDto>>> ByConversation(string conversationId, [FromQuery] int limit = 50, [FromQuery] int offset = 0)
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
                    FileUrl = m.FileUrl,
                    FileName = m.FileName,
                    FileSize = m.FileSize,
                    SentAt = m.SentAt,
                    IsRead = m.IsRead
                })
                .ToListAsync();
            msgs.Reverse();
            return Ok(msgs);
        }

        [HttpPost("mark-read/{conversationId}")]
        public async Task<IActionResult> MarkRead(string conversationId, [FromQuery] string readerId)
        {
            var unread = await _context.Messages
                .Where(m => m.IdConversation == conversationId && m.IsRead == 0 && m.IdSender != readerId)
                .ToListAsync();
            foreach (var m in unread) m.IsRead = 1;
            await _context.SaveChangesAsync();

            // Broadcast cập nhật đã đọc tới group hội thoại
            await _hub.Clients.Group($"conv:{conversationId}").SendAsync("MessagesMarkedRead", new { conversationId, readerId });

            // Cập nhật badge cho reader
            var convIds = await _context.ConversationMembers
                .Where(cm => cm.IdUser == readerId)
                .Select(cm => cm.IdConversation)
                .ToListAsync();
            var unreadCount = await _context.Messages
                .Where(m => convIds.Contains(m.IdConversation) && m.IsRead == 0 && m.IdSender != readerId)
                .CountAsync();
            await _hub.Clients.Group($"user:{readerId}").SendAsync("UnreadCountUpdated", new { userId = readerId, count = unreadCount });
            return NoContent();
        }

        [HttpGet("unread-count/{userId}")]
        public async Task<ActionResult<int>> UnreadCount(string userId)
        {
            // Tất cả tin nhắn chưa đọc trong các hội thoại mà user là member
            var convIds = await _context.ConversationMembers
                .Where(cm => cm.IdUser == userId)
                .Select(cm => cm.IdConversation)
                .ToListAsync();

            var count = await _context.Messages
                .Where(m => convIds.Contains(m.IdConversation) && m.IsRead == 0 && m.IdSender != userId)
                .CountAsync();
            return Ok(count);
        }
    }
}


