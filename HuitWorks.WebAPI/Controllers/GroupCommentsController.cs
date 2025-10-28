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
    public class GroupCommentsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public GroupCommentsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/GroupComments - Lấy danh sách comments với query parameter
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GroupCommentDto>>> GetCommentsByQuery(
            [FromQuery] string? postId = null,
            [FromQuery] string? userId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            if (string.IsNullOrEmpty(postId))
                return BadRequest("postId là bắt buộc");

            return await GetPostComments(postId, userId, page, pageSize);
        }

        // GET: api/GroupComments/post/{postId} - Lấy danh sách comments của post
        [HttpGet("post/{postId}")]
        public async Task<ActionResult<IEnumerable<GroupCommentDto>>> GetPostComments(
            string postId, 
            [FromQuery] string? userId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            // Kiểm tra post có tồn tại không
            var post = await _context.GroupPosts
                .Include(p => p.SocialGroup)
                .FirstOrDefaultAsync(p => p.IdPost == postId);

            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Kiểm tra quyền xem comments
            if (userId != null)
            {
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == post.IdGroup && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole == null && post.SocialGroup!.Privacy != "public")
                    return Forbid("Bạn không có quyền xem bình luận trong nhóm này");
            }
            else if (post.SocialGroup!.Privacy != "public")
            {
                return Forbid("Bạn cần đăng nhập để xem bình luận");
            }

            var comments = await _context.GroupComments
                .Include(c => c.User)
                .Include(c => c.Replies)
                .Include(c => c.GroupReactions)
                .Where(c => c.IdPost == postId && c.ParentId == null) // Chỉ lấy comments gốc
                .OrderBy(c => c.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(c => new GroupCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    UserName = c.User!.UserName,
                    UserAvatar = c.User.AvatarUrl,
                    Content = c.Content,
                    ParentId = c.ParentId,
                    CreatedAt = c.CreatedAt,
                    ReplyCount = c.Replies.Count(),
                    ReactionCount = c.GroupReactions.Count(),
                    IsLikedByUser = userId != null && c.GroupReactions.Any(r => r.IdUser == userId),
                    UserReaction = userId != null ? c.GroupReactions
                        .Where(r => r.IdUser == userId)
                        .Select(r => r.Reaction)
                        .FirstOrDefault() : null
                })
                .ToListAsync();

            return Ok(comments);
        }

        // GET: api/GroupComments/{id}/replies - Lấy replies của comment
        [HttpGet("{id}/replies")]
        public async Task<ActionResult<IEnumerable<GroupCommentDto>>> GetCommentReplies(
            string id, 
            [FromQuery] string? userId = null)
        {
            var comment = await _context.GroupComments
                .Include(c => c.GroupPost)
                    .ThenInclude(p => p.SocialGroup)
                .FirstOrDefaultAsync(c => c.IdComment == id);

            if (comment == null)
                return NotFound("Không tìm thấy bình luận");

            // Kiểm tra quyền xem replies
            if (userId != null)
            {
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == comment.GroupPost!.IdGroup && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole == null && comment.GroupPost!.SocialGroup!.Privacy != "public")
                    return Forbid("Bạn không có quyền xem bình luận trong nhóm này");
            }
            else if (comment.GroupPost!.SocialGroup!.Privacy != "public")
            {
                return Forbid("Bạn cần đăng nhập để xem bình luận");
            }

            var replies = await _context.GroupComments
                .Include(c => c.User)
                .Include(c => c.GroupReactions)
                .Where(c => c.ParentId == id)
                .OrderBy(c => c.CreatedAt)
                .Select(c => new GroupCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    UserName = c.User!.UserName,
                    UserAvatar = c.User.AvatarUrl,
                    Content = c.Content,
                    ParentId = c.ParentId,
                    CreatedAt = c.CreatedAt,
                    ReplyCount = 0, // Replies không có sub-replies
                    ReactionCount = c.GroupReactions.Count(),
                    IsLikedByUser = userId != null && c.GroupReactions.Any(r => r.IdUser == userId),
                    UserReaction = userId != null ? c.GroupReactions
                        .Where(r => r.IdUser == userId)
                        .Select(r => r.Reaction)
                        .FirstOrDefault() : null
                })
                .ToListAsync();

            return Ok(replies);
        }

        // GET: api/GroupComments/{id} - Lấy chi tiết comment
        [HttpGet("{id}")]
        public async Task<ActionResult<GroupCommentDto>> GetComment(string id, [FromQuery] string? userId = null)
        {
            var comment = await _context.GroupComments
                .Include(c => c.User)
                .Include(c => c.GroupPost)
                    .ThenInclude(p => p.SocialGroup)
                .Include(c => c.Replies)
                .Include(c => c.GroupReactions)
                .FirstOrDefaultAsync(c => c.IdComment == id);

            if (comment == null)
                return NotFound("Không tìm thấy bình luận");

            // Kiểm tra quyền xem comment
            if (userId != null)
            {
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == comment.GroupPost!.IdGroup && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole == null && comment.GroupPost!.SocialGroup!.Privacy != "public")
                    return Forbid("Bạn không có quyền xem bình luận này");
            }
            else if (comment.GroupPost!.SocialGroup!.Privacy != "public")
            {
                return Forbid("Bạn cần đăng nhập để xem bình luận này");
            }

            var commentDto = new GroupCommentDto
            {
                IdComment = comment.IdComment,
                IdPost = comment.IdPost,
                IdUser = comment.IdUser,
                UserName = comment.User!.UserName,
                UserAvatar = comment.User.AvatarUrl,
                Content = comment.Content,
                ParentId = comment.ParentId,
                CreatedAt = comment.CreatedAt,
                ReplyCount = comment.Replies.Count(),
                ReactionCount = comment.GroupReactions.Count(),
                Replies = comment.Replies
                    .OrderBy(r => r.CreatedAt)
                    .Select(r => new GroupCommentDto
                    {
                        IdComment = r.IdComment,
                        IdPost = r.IdPost,
                        IdUser = r.IdUser,
                        UserName = r.User!.UserName,
                        UserAvatar = r.User.AvatarUrl,
                        Content = r.Content,
                        ParentId = r.ParentId,
                        CreatedAt = r.CreatedAt,
                        ReplyCount = 0,
                        ReactionCount = r.GroupReactions.Count(),
                        IsLikedByUser = userId != null && r.GroupReactions.Any(reaction => reaction.IdUser == userId),
                        UserReaction = userId != null ? r.GroupReactions
                            .Where(reaction => reaction.IdUser == userId)
                            .Select(reaction => reaction.Reaction)
                            .FirstOrDefault() : null
                    }).ToList(),
                IsLikedByUser = userId != null && comment.GroupReactions.Any(r => r.IdUser == userId),
                UserReaction = userId != null ? comment.GroupReactions
                    .Where(r => r.IdUser == userId)
                    .Select(r => r.Reaction)
                    .FirstOrDefault() : null
            };

            return Ok(commentDto);
        }

        // POST: api/GroupComments - Tạo comment mới
        [HttpPost]
        public async Task<ActionResult<GroupCommentDto>> CreateComment([FromBody] CreateGroupCommentDto input)
        {
            // Kiểm tra post có tồn tại không
            var post = await _context.GroupPosts
                .Include(p => p.SocialGroup)
                .FirstOrDefaultAsync(p => p.IdPost == input.IdPost);

            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Kiểm tra user có quyền comment không
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == post.IdGroup && m.IdUser == input.IdUser && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (userRole == null)
                return Forbid("Bạn không phải là thành viên của nhóm này");

            // Nếu là reply, kiểm tra comment cha có tồn tại không
            if (!string.IsNullOrEmpty(input.ParentId))
            {
                var parentComment = await _context.GroupComments
                    .FirstOrDefaultAsync(c => c.IdComment == input.ParentId && c.IdPost == input.IdPost);

                if (parentComment == null)
                    return NotFound("Không tìm thấy bình luận cha");
            }

            var comment = new GroupComment
            {
                IdComment = Guid.NewGuid().ToString("N"),
                IdPost = input.IdPost,
                IdUser = input.IdUser,
                Content = input.Content,
                ParentId = input.ParentId,
                CreatedAt = DateTime.UtcNow
            };

            _context.GroupComments.Add(comment);
            await _context.SaveChangesAsync();

            // Lấy thông tin user
            var user = await _context.Users.FindAsync(input.IdUser);

            var commentDto = new GroupCommentDto
            {
                IdComment = comment.IdComment,
                IdPost = comment.IdPost,
                IdUser = comment.IdUser,
                UserName = user!.UserName,
                UserAvatar = user.AvatarUrl,
                Content = comment.Content,
                ParentId = comment.ParentId,
                CreatedAt = comment.CreatedAt,
                ReplyCount = 0,
                ReactionCount = 0,
                Replies = new List<GroupCommentDto>(),
                IsLikedByUser = false,
                UserReaction = null
            };

            return CreatedAtAction(nameof(GetComment), new { id = comment.IdComment }, commentDto);
        }

        // PUT: api/GroupComments/{id} - Cập nhật comment
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateComment(string id, [FromBody] UpdateGroupCommentDto input, [FromQuery] string userId)
        {
            var comment = await _context.GroupComments
                .Include(c => c.GroupPost)
                .FirstOrDefaultAsync(c => c.IdComment == id);

            if (comment == null)
                return NotFound("Không tìm thấy bình luận");

            // Chỉ người comment hoặc admin/owner mới được sửa
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == comment.GroupPost!.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (comment.IdUser != userId && userRole != "admin" && userRole != "owner")
                return Forbid("Bạn không có quyền sửa bình luận này");

            if (!string.IsNullOrEmpty(input.Content))
                comment.Content = input.Content;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/GroupComments/{id} - Xóa comment
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteComment(string id, [FromQuery] string userId)
        {
            var comment = await _context.GroupComments
                .Include(c => c.GroupPost)
                .FirstOrDefaultAsync(c => c.IdComment == id);

            if (comment == null)
                return NotFound("Không tìm thấy bình luận");

            // Chỉ người comment hoặc admin/owner mới được xóa
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == comment.GroupPost!.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (comment.IdUser != userId && userRole != "admin" && userRole != "owner")
                return Forbid("Bạn không có quyền xóa bình luận này");

            _context.GroupComments.Remove(comment);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // POST: api/GroupComments/{id}/reaction - Thêm reaction cho comment
        [HttpPost("{id}/reaction")]
        public async Task<IActionResult> AddCommentReaction(string id, [FromBody] CreateGroupReactionDto input, [FromQuery] string userId)
        {
            var comment = await _context.GroupComments
                .Include(c => c.GroupPost)
                .FirstOrDefaultAsync(c => c.IdComment == id);

            if (comment == null)
                return NotFound("Không tìm thấy bình luận");

            // Kiểm tra user có quyền tương tác không
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == comment.GroupPost!.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (userRole == null)
                return Forbid("Bạn không có quyền tương tác với bình luận này");

            // Kiểm tra đã có reaction chưa
            var existingReaction = await _context.GroupReactions
                .FirstOrDefaultAsync(r => r.EntityType == "comment" && r.EntityId == id && r.IdUser == userId);

            if (existingReaction != null)
            {
                // Cập nhật reaction
                existingReaction.Reaction = input.Reaction;
            }
            else
            {
                // Tạo reaction mới
                var reaction = new GroupReaction
                {
                    IdReaction = Guid.NewGuid().ToString("N"),
                    EntityType = "comment",
                    EntityId = id,
                    IdUser = userId,
                    Reaction = input.Reaction,
                    CreatedAt = DateTime.UtcNow
                };
                _context.GroupReactions.Add(reaction);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã thêm reaction thành công" });
        }

        // DELETE: api/GroupComments/{id}/reaction - Xóa reaction của comment
        [HttpDelete("{id}/reaction")]
        public async Task<IActionResult> RemoveCommentReaction(string id, [FromQuery] string userId)
        {
            var reaction = await _context.GroupReactions
                .FirstOrDefaultAsync(r => r.EntityType == "comment" && r.EntityId == id && r.IdUser == userId);

            if (reaction == null)
                return NotFound("Không tìm thấy reaction");

            _context.GroupReactions.Remove(reaction);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa reaction thành công" });
        }

        // GET: api/GroupComments/{id}/reactions - Lấy danh sách reactions của comment
        [HttpGet("{id}/reactions")]
        public async Task<ActionResult<IEnumerable<GroupReactionDto>>> GetCommentReactions(string id)
        {
            var reactions = await _context.GroupReactions
                .Include(r => r.User)
                .Where(r => r.EntityType == "comment" && r.EntityId == id)
                .OrderBy(r => r.CreatedAt)
                .Select(r => new GroupReactionDto
                {
                    IdReaction = r.IdReaction,
                    EntityType = r.EntityType,
                    EntityId = r.EntityId,
                    IdUser = r.IdUser,
                    UserName = r.User!.UserName,
                    UserAvatar = r.User.AvatarUrl,
                    Reaction = r.Reaction,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            return Ok(reactions);
        }
    }
}
