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
    public class GroupReactionsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public GroupReactionsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/GroupReactions - Lấy danh sách reactions với query parameter
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GroupReactionDto>>> GetReactionsByQuery(
            [FromQuery] string? entityType = null,
            [FromQuery] string? entityId = null,
            [FromQuery] string? userId = null)
        {
            if (string.IsNullOrEmpty(entityType) || string.IsNullOrEmpty(entityId))
                return BadRequest("entityType và entityId là bắt buộc");

            return await GetReactions(entityType, entityId, userId);
        }

        // GET: api/GroupReactions/{entityType}/{entityId} - Lấy danh sách reactions
        [HttpGet("{entityType}/{entityId}")]
        public async Task<ActionResult<IEnumerable<GroupReactionDto>>> GetReactions(
            string entityType, 
            string entityId,
            [FromQuery] string? userId = null)
        {
            var reactions = await _context.GroupReactions
                .Where(r => r.EntityType == entityType && r.EntityId == entityId)
                .Include(r => r.User)
                .Select(r => new GroupReactionDto
                {
                    IdReaction = r.IdReaction,
                    EntityType = r.EntityType,
                    EntityId = r.EntityId,
                    IdUser = r.IdUser,
                    UserName = r.User != null ? r.User.UserName : "Unknown",
                    Reaction = r.Reaction,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            return Ok(reactions);
        }

        // POST: api/GroupReactions - Tạo reaction mới
        [HttpPost]
        public async Task<ActionResult<GroupReactionDto>> CreateReaction([FromBody] CreateGroupReactionDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra reaction đã tồn tại chưa - dùng AsNoTracking để tránh load navigation properties
            var existingReaction = await _context.GroupReactions
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.EntityType == dto.EntityType && 
                                        r.EntityId == dto.EntityId && 
                                        r.IdUser == dto.IdUser);

            if (existingReaction != null)
            {
                // Cập nhật reaction hiện tại - cần load lại với tracking
                var trackedReaction = await _context.GroupReactions
                    .FirstOrDefaultAsync(r => r.IdReaction == existingReaction.IdReaction);
                
                if (trackedReaction != null)
                {
                    trackedReaction.Reaction = dto.Reaction;
                    trackedReaction.CreatedAt = DateTime.UtcNow;
                }
            }
            else
            {
                // Tạo reaction mới
                var reaction = new GroupReaction
                {
                    IdReaction = Guid.NewGuid().ToString("N"),
                    EntityType = dto.EntityType,
                    EntityId = dto.EntityId,
                    IdUser = dto.IdUser,
                    Reaction = dto.Reaction,
                    CreatedAt = DateTime.UtcNow
                };

                _context.GroupReactions.Add(reaction);
            }

            await _context.SaveChangesAsync();
            
            // Lấy lại reaction sau khi save để có đúng IdReaction
            var savedReaction = await _context.GroupReactions
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.EntityType == dto.EntityType && 
                                        r.EntityId == dto.EntityId && 
                                        r.IdUser == dto.IdUser);

            var user = await _context.Users.FindAsync(dto.IdUser);
            var reactionDto = new GroupReactionDto
            {
                IdReaction = savedReaction?.IdReaction ?? Guid.NewGuid().ToString("N"),
                EntityType = dto.EntityType,
                EntityId = dto.EntityId,
                IdUser = dto.IdUser,
                UserName = user?.UserName ?? "Unknown",
                Reaction = dto.Reaction,
                CreatedAt = savedReaction?.CreatedAt ?? DateTime.UtcNow
            };

            return Ok(reactionDto);
        }

        // DELETE: api/GroupReactions/{entityType}/{entityId}/{userId} - Xóa reaction
        [HttpDelete("{entityType}/{entityId}/{userId}")]
        public async Task<IActionResult> DeleteReaction(string entityType, string entityId, string userId)
        {
            var reaction = await _context.GroupReactions
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.EntityType == entityType && 
                                        r.EntityId == entityId && 
                                        r.IdUser == userId);
            
            if (reaction != null)
            {
                // Load lại với tracking để có thể xóa
                var trackedReaction = await _context.GroupReactions
                    .FirstOrDefaultAsync(r => r.IdReaction == reaction.IdReaction);
                    
                if (trackedReaction != null)
                {
                    _context.GroupReactions.Remove(trackedReaction);
                }
            }
            else
            {
                return NotFound("Không tìm thấy reaction");
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa reaction thành công" });
        }
    }
}
