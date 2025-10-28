using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Hubs
{
    public class ChatHub : Hub
    {
        private readonly JobConnectDbContext _context;
        public ChatHub(JobConnectDbContext context)
        {
            _context = context;
        }

        private string GetUserId() 
        {
            // Thử lấy từ Context.User trước
            var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
            Console.WriteLine($"GetUserId: Context.User is null: {Context.User == null}");
            if (Context.User != null)
            {
                Console.WriteLine($"GetUserId: Claims count: {Context.User.Claims.Count()}");
                foreach (var claim in Context.User.Claims)
                {
                    Console.WriteLine($"GetUserId: Claim - {claim.Type}: {claim.Value}");
                }
            }
            
            // Nếu không có từ Context.User, thử lấy từ query string
            if (string.IsNullOrEmpty(userId))
            {
                userId = Context.GetHttpContext()?.Request.Query["userId"].FirstOrDefault() ?? string.Empty;
                Console.WriteLine($"GetUserId: From query string: '{userId}'");
            }
            
            Console.WriteLine($"GetUserId: Final userId: '{userId}'");
            return userId;
        }

        public async Task JoinConversation(string conversationId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return;

            var isMember = _context.ConversationMembers.Any(m => m.IdConversation == conversationId && m.IdUser == userId);
            if (!isMember) return;

            await Groups.AddToGroupAsync(Context.ConnectionId, $"conv:{conversationId}");
        }

        public async Task LeaveConversation(string conversationId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"conv:{conversationId}");
        }

        public async Task SendMessageToConversation(string conversationId, string? content, string messageType = "text", string? fileUrl = null, string? fileName = null, long? fileSize = null)
        {
            Console.WriteLine($"=== ChatHub.SendMessageToConversation START ===");
            Console.WriteLine($"conversationId: {conversationId}");
            Console.WriteLine($"content: {content}");
            Console.WriteLine($"messageType: {messageType}");
            Console.WriteLine($"fileUrl: {fileUrl}");
            Console.WriteLine($"fileName: {fileName}");
            Console.WriteLine($"fileSize: {fileSize}");
            
            var senderId = GetUserId();
            Console.WriteLine($"senderId: {senderId}");
            if (string.IsNullOrEmpty(senderId)) 
            {
                Console.WriteLine("ERROR: senderId is null or empty");
                return;
            }

            var isMember = _context.ConversationMembers.Any(m => m.IdConversation == conversationId && m.IdUser == senderId);
            Console.WriteLine($"isMember: {isMember}");
            if (!isMember) 
            {
                Console.WriteLine("ERROR: User is not a member of this conversation");
                return;
            }

            var msg = new Message
            {
                IdMessage = Guid.NewGuid().ToString("N"),
                IdConversation = conversationId,
                IdSender = senderId,
                Content = content,
                MessageType = messageType,
                FileUrl = fileUrl,
                FileName = fileName,
                FileSize = fileSize,
                SentAt = DateTime.UtcNow,
                IsRead = 0
            };
            
            Console.WriteLine($"Created message with IdMessage: {msg.IdMessage}");
            _context.Messages.Add(msg);
            
            try
            {
                await _context.SaveChangesAsync();
                Console.WriteLine($"Message saved to database successfully: {msg.IdMessage}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR saving message to database: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                throw;
            }

            // Gửi cho tất cả thành viên trong nhóm conversation, trừ chính sender
            var otherMembers = _context.ConversationMembers
                .Where(m => m.IdConversation == conversationId && m.IdUser != senderId)
                .Select(m => m.IdUser)
                .ToList();
            
            if (otherMembers.Any())
            {
                await Clients.Users(otherMembers).SendAsync("ReceiveMessage", new
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
                Console.WriteLine($"ReceiveMessage sent to {otherMembers.Count} other members");
            }

            // Gửi AckMessage cho chính sender
            Console.WriteLine($"Sending AckMessage to caller with messageId: {msg.IdMessage}");
            await Clients.Caller.SendAsync("AckMessage", new
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
            Console.WriteLine($"AckMessage sent successfully");
        }

        public override async Task OnConnectedAsync()
        {
            var userId = GetUserId();
            if (!string.IsNullOrEmpty(userId))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"user:{userId}");

                var conversationIds = _context.ConversationMembers
                    .Where(m => m.IdUser == userId)
                    .Select(m => m.IdConversation)
                    .ToList();

                foreach (var convId in conversationIds)
                {
                    await Groups.AddToGroupAsync(Context.ConnectionId, $"conv:{convId}");
                }
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
        }
    }
}