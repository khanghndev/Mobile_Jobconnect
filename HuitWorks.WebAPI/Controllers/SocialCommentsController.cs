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
    public class SocialCommentsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public SocialCommentsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpGet("by-post/{postId}")]
        public async Task<ActionResult<IEnumerable<SocialCommentDto>>> GetByPost(string postId)
        {
            var currentUserId = User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            
            var list = await _context.SocialComments
                .Include(c => c.User)
                .Include(c => c.Likes)
                .Where(c => c.IdPost == postId && c.IsDeleted == false)
                .OrderBy(c => c.CreatedAt)
                .Select(c => new SocialCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    ParentComment = c.ParentComment,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    IsEdited = c.IsEdited,
                    LikesCount = c.LikesCount,
                    RepliesCount = c.RepliesCount,
                    UserName = c.User != null ? c.User.UserName : null,
                    AvatarUrl = c.User != null ? c.User.AvatarUrl : null,
                    IsLiked = c.Likes.Any(l => l.IdUser == currentUserId),
                    CanEdit = c.IdUser == currentUserId,
                    CanDelete = c.IdUser == currentUserId
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpGet("replies/{parentId}")]
        public async Task<ActionResult<IEnumerable<SocialCommentDto>>> GetReplies(string parentId)
        {
            var currentUserId = User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            
            var list = await _context.SocialComments
                .Include(c => c.User)
                .Include(c => c.Likes)
                .Where(c => c.ParentComment == parentId && c.IsDeleted == false)
                .OrderBy(c => c.CreatedAt)
                .Select(c => new SocialCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    ParentComment = c.ParentComment,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    IsEdited = c.IsEdited,
                    LikesCount = c.LikesCount,
                    RepliesCount = c.RepliesCount,
                    UserName = c.User != null ? c.User.UserName : null,
                    AvatarUrl = c.User != null ? c.User.AvatarUrl : null,
                    IsLiked = c.Likes.Any(l => l.IdUser == currentUserId),
                    CanEdit = c.IdUser == currentUserId,
                    CanDelete = c.IdUser == currentUserId
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SocialCommentDto>> GetById(string id)
        {
            var currentUserId = User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            
            var comment = await _context.SocialComments
                .Include(c => c.User)
                .Include(c => c.Likes)
                .Where(c => c.IdComment == id && c.IsDeleted == false)
                .Select(c => new SocialCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    ParentComment = c.ParentComment,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    IsEdited = c.IsEdited,
                    LikesCount = c.LikesCount,
                    RepliesCount = c.RepliesCount,
                    UserName = c.User != null ? c.User.UserName : null,
                    AvatarUrl = c.User != null ? c.User.AvatarUrl : null,
                    IsLiked = c.Likes.Any(l => l.IdUser == currentUserId),
                    CanEdit = c.IdUser == currentUserId,
                    CanDelete = c.IdUser == currentUserId
                })
                .FirstOrDefaultAsync();

            if (comment == null) return NotFound();
            return Ok(comment);
        }

        [HttpPost]
        public async Task<ActionResult<SocialCommentDto>> Create([FromBody] CreateSocialCommentDto input)
        {
            try
            {
                // Validation
                if (string.IsNullOrEmpty(input.IdPost) || string.IsNullOrEmpty(input.IdUser) || string.IsNullOrEmpty(input.Content))
                {
                    return BadRequest(new { message = "Thiếu thông tin bắt buộc" });
                }

                // Kiểm tra post có tồn tại không
                var post = await _context.SocialPosts.FindAsync(input.IdPost);
                if (post == null)
                {
                    return BadRequest(new { message = "Bài đăng không tồn tại" });
                }

                // Kiểm tra user có tồn tại không
                var user = await _context.Users.FindAsync(input.IdUser);
                if (user == null)
                {
                    return BadRequest(new { message = "Người dùng không tồn tại" });
                }

                var entity = new SocialComment
                {
                    IdComment = Guid.NewGuid().ToString("N"),
                    IdPost = input.IdPost,
                    IdUser = input.IdUser,
                    ParentComment = input.ParentComment,
                    Content = input.Content,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsDeleted = false,
                    LikesCount = 0,
                    RepliesCount = 0,
                    IsEdited = false
                };
                
                _context.SocialComments.Add(entity);
                
                // Cập nhật số lượng replies cho parent comment
                if (!string.IsNullOrEmpty(input.ParentComment))
                {
                    var parentComment = await _context.SocialComments.FindAsync(input.ParentComment);
                    if (parentComment != null)
                    {
                        parentComment.RepliesCount++;
                        parentComment.UpdatedAt = DateTime.UtcNow;
                    }
                }
                
                await _context.SaveChangesAsync();

                var dto = new SocialCommentDto
                {
                    IdComment = entity.IdComment,
                    IdPost = entity.IdPost,
                    IdUser = entity.IdUser,
                    ParentComment = entity.ParentComment,
                    Content = entity.Content,
                    CreatedAt = entity.CreatedAt,
                    UpdatedAt = entity.UpdatedAt,
                    IsEdited = entity.IsEdited,
                    LikesCount = entity.LikesCount,
                    RepliesCount = entity.RepliesCount,
                    UserName = user.UserName,
                    AvatarUrl = user.AvatarUrl,
                    IsLiked = false,
                    CanEdit = true,
                    CanDelete = true
                };
                return CreatedAtAction(nameof(GetById), new { id = entity.IdComment }, dto);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Có lỗi xảy ra khi tạo comment", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateSocialCommentDto input)
        {
            var entity = await _context.SocialComments.FindAsync(id);
            if (entity == null || entity.IsDeleted) return NotFound();

            // Kiểm tra quyền sở hữu
            if (entity.IdUser != input.IdUser) return Forbid();

            entity.Content = input.Content;
            entity.UpdatedAt = DateTime.UtcNow;
            entity.IsEdited = true;
            entity.EditedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id, [FromQuery] string userId)
        {
            var entity = await _context.SocialComments.FindAsync(id);
            if (entity == null || entity.IsDeleted) return NotFound();

            // Kiểm tra quyền sở hữu
            if (entity.IdUser != userId) return Forbid();

            // Soft delete
            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.UtcNow;
            entity.DeletedBy = userId;
            entity.UpdatedAt = DateTime.UtcNow;

            // Cập nhật số lượng replies cho parent comment
            if (!string.IsNullOrEmpty(entity.ParentComment))
            {
                var parentComment = await _context.SocialComments.FindAsync(entity.ParentComment);
                if (parentComment != null)
                {
                    parentComment.RepliesCount = Math.Max(0, parentComment.RepliesCount - 1);
                    parentComment.UpdatedAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPost("{id}/like")]
        public async Task<IActionResult> LikeComment(string id, [FromBody] LikeCommentDto input)
        {
            var comment = await _context.SocialComments.FindAsync(id);
            if (comment == null || comment.IsDeleted) return NotFound();

            // Kiểm tra xem user đã like chưa
            var existingLike = await _context.SocialCommentLikes
                .FirstOrDefaultAsync(l => l.IdComment == id && l.IdUser == input.IdUser);

            if (existingLike != null)
            {
                // Bỏ like
                _context.SocialCommentLikes.Remove(existingLike);
                comment.LikesCount = Math.Max(0, comment.LikesCount - 1);
            }
            else
            {
                // Thêm like
                var like = new SocialCommentLike
                {
                    IdLike = Guid.NewGuid().ToString("N"),
                    IdComment = id,
                    IdUser = input.IdUser,
                    CreatedAt = DateTime.UtcNow
                };
                _context.SocialCommentLikes.Add(like);
                comment.LikesCount++;
            }

            comment.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(new { isLiked = existingLike == null, likesCount = comment.LikesCount });
        }

        [HttpPost("{id}/report")]
        public async Task<IActionResult> ReportComment(string id, [FromBody] ReportCommentDto input)
        {
            var comment = await _context.SocialComments.FindAsync(id);
            if (comment == null || comment.IsDeleted) return NotFound();

            // Kiểm tra xem user đã report chưa
            var existingReport = await _context.SocialCommentReports
                .FirstOrDefaultAsync(r => r.IdComment == id && r.ReporterId == input.ReporterId);

            if (existingReport != null)
            {
                return BadRequest(new { message = "Bạn đã báo cáo comment này rồi" });
            }

            var report = new SocialCommentReport
            {
                IdReport = Guid.NewGuid().ToString("N"),
                IdComment = id,
                ReporterId = input.ReporterId,
                Reason = input.Reason,
                Status = "pending",
                CreatedAt = DateTime.UtcNow
            };

            _context.SocialCommentReports.Add(report);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã gửi báo cáo thành công" });
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<SocialCommentDto>>> GetByUser(string userId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var comments = await _context.SocialComments
                .Where(c => c.IdUser == userId && c.IsDeleted == false)
                .OrderByDescending(c => c.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(c => new SocialCommentDto
                {
                    IdComment = c.IdComment,
                    IdPost = c.IdPost,
                    IdUser = c.IdUser,
                    ParentComment = c.ParentComment,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    IsEdited = c.IsEdited,
                    LikesCount = c.LikesCount,
                    RepliesCount = c.RepliesCount,
                    UserName = c.User != null ? c.User.UserName : null,
                    AvatarUrl = c.User != null ? c.User.AvatarUrl : null
                })
                .ToListAsync();

            return Ok(comments);
        }
    }
}