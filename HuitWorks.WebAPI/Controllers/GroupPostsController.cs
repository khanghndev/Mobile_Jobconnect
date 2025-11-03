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
    public class GroupPostsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public GroupPostsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/GroupPosts - Lấy danh sách posts với query parameter
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GroupPostListItemDto>>> GetGroupPostsByQuery(
            [FromQuery] string? groupId = null,
            [FromQuery] string? userId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                if (string.IsNullOrEmpty(groupId))
                    return BadRequest("groupId là bắt buộc");

                // Kiểm tra group
                var group = await _context.SocialGroups.FindAsync(groupId);
                if (group == null)
                    return NotFound("Không tìm thấy nhóm");

                var posts = await _context.GroupPosts
                    .Include(p => p.User)
                    .Where(p => p.IdGroup == groupId && p.ApprovalStatus == "approved")
                    .OrderByDescending(p => p.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                // Temporarily skip counts to avoid DB alias problems; front-end can still render
                var commentCounts = new Dictionary<string, int>();
                var reactionCounts = new Dictionary<string, int>();
                var likedMap = new Dictionary<string, (bool liked, string? reaction)>();

                var result = posts.Select(p => new GroupPostListItemDto
                {
                    IdPost = p.IdPost,
                    IdGroup = p.IdGroup,
                    IdUser = p.IdUser,
                    UserName = p.User?.UserName ?? "Unknown",
                    UserAvatar = p.User?.AvatarUrl,
                    Content = p.Content,
                    MediaUrl = p.MediaUrl,
                    PostType = p.PostType,
                    CreatedAt = p.CreatedAt,
                    CommentCount = commentCounts.TryGetValue(p.IdPost, out var cc) ? cc : 0,
                    ReactionCount = reactionCounts.TryGetValue(p.IdPost, out var rc) ? rc : 0,
                    IsLikedByUser = likedMap.ContainsKey(p.IdPost),
                    UserReaction = likedMap.TryGetValue(p.IdPost, out var lr) ? lr.reaction : null
                }).ToList();

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/GroupPosts/group/{groupId} - Lấy danh sách posts trong group
        [HttpGet("group/{groupId}")]
        public async Task<ActionResult<IEnumerable<GroupPostListItemDto>>> GetGroupPosts(
            string groupId,
            [FromQuery] string? userId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                // Kiểm tra group có tồn tại không
                var group = await _context.SocialGroups.FindAsync(groupId);
                if (group == null)
                    return NotFound("Không tìm thấy nhóm");

                // Kiểm tra user có quyền xem posts không
                if (userId != null)
                {
                    var userRole = await _context.GroupMembers
                        .Where(m => m.IdGroup == groupId && m.IdUser == userId && m.Status == "active")
                        .Select(m => m.RoleInGroup)
                        .FirstOrDefaultAsync();

                    if (userRole == null && group.Privacy != "public")
                        return Forbid("Bạn không có quyền xem bài đăng trong nhóm này");
                }
                else if (group.Privacy != "public")
                {
                    return Forbid("Nhóm này yêu cầu đăng nhập để xem bài đăng");
                }

                var posts = await _context.GroupPosts
                    .Where(p => p.IdGroup == groupId && p.ApprovalStatus == "approved")
                    .OrderByDescending(p => p.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                // Load users separately
                var userIds = posts.Select(p => p.IdUser).Distinct().ToList();
                var users = await _context.Users
                    .Where(u => userIds.Contains(u.IdUser))
                    .ToDictionaryAsync(u => u.IdUser, u => u);

                // Load comments and reactions separately
                var postIds = posts.Select(p => p.IdPost).ToList();

                // Tạm thời bỏ qua counts để tránh lỗi SQL
                var comments = new Dictionary<string, int>();
                var reactions = new Dictionary<string, List<object>>();
                var userReactions = new Dictionary<string, string>();

                var postDtos = posts.Select(p => new GroupPostListItemDto
                {
                    IdPost = p.IdPost,
                    IdGroup = p.IdGroup,
                    IdUser = p.IdUser,
                    UserName = users.TryGetValue(p.IdUser, out var user) ? user.UserName : "Unknown",
                    UserAvatar = users.TryGetValue(p.IdUser, out var user2) ? user2.AvatarUrl : null,
                    Content = p.Content,
                    MediaUrl = p.MediaUrl,
                    PostType = p.PostType,
                    ApprovalStatus = p.ApprovalStatus,
                    CreatedAt = p.CreatedAt,
                    CommentCount = comments.TryGetValue(p.IdPost, out var commentCount) ? commentCount : 0,
                    ReactionCount = reactions.TryGetValue(p.IdPost, out var reactionList) ? reactionList.Count : 0,
                    IsLikedByUser = userReactions.ContainsKey(p.IdPost),
                    UserReaction = userReactions.TryGetValue(p.IdPost, out var userReaction) ? userReaction : null
                }).ToList();

                return Ok(postDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/GroupPosts/{id} - Lấy chi tiết post
        [HttpGet("{id}")]
        public async Task<ActionResult<GroupPostDto>> GetPost(string id, [FromQuery] string? userId = null)
        {
            var post = await _context.GroupPosts
                .Include(p => p.User)
                .Include(p => p.SocialGroup)
                .Include(p => p.GroupComments)
                    .ThenInclude(c => c.User)
                .FirstOrDefaultAsync(p => p.IdPost == id);

            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Kiểm tra quyền xem post
            if (userId != null)
            {
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == post.IdGroup && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole == null && post.SocialGroup!.Privacy != "public")
                    return Forbid("Bạn không có quyền xem bài đăng này");
            }
            else if (post.SocialGroup!.Privacy != "public")
            {
                return Forbid("Bạn cần đăng nhập để xem bài đăng này");
            }

            // Load reactions separately
            var postReactions = await _context.GroupReactions
                .Include(r => r.User)
                .Where(r => r.EntityType == "post" && r.EntityId == post.IdPost)
                .ToListAsync();

            // Load comment reactions separately
            var commentIds = post.GroupComments.Select(c => c.IdComment).ToList();
            var commentReactions = await _context.GroupReactions
                .Where(r => r.EntityType == "comment" && commentIds.Contains(r.EntityId))
                .ToListAsync();

            var postDto = new GroupPostDto
            {
                IdPost = post.IdPost,
                IdGroup = post.IdGroup,
                IdUser = post.IdUser,
                UserName = post.User!.UserName,
                UserAvatar = post.User.AvatarUrl,
                Content = post.Content,
                MediaUrl = post.MediaUrl,
                PostType = post.PostType,
                CreatedAt = post.CreatedAt,
                UpdatedAt = post.UpdatedAt,
                CommentCount = post.GroupComments.Count(),
                ReactionCount = postReactions.Count,
                Reactions = postReactions.Select(r => new GroupReactionDto
                {
                    IdReaction = r.IdReaction,
                    EntityType = r.EntityType,
                    EntityId = r.EntityId,
                    IdUser = r.IdUser,
                    UserName = r.User?.UserName ?? "Unknown",
                    UserAvatar = r.User?.AvatarUrl,
                    Reaction = r.Reaction,
                    CreatedAt = r.CreatedAt
                }).ToList(),
                Comments = post.GroupComments
                    .Where(c => c.ParentId == null) // Chỉ lấy comments gốc
                    .OrderBy(c => c.CreatedAt)
                    .Select(c =>
                    {
                        var reactionsForComment = commentReactions.Where(r => r.EntityId == c.IdComment).ToList();
                        return new GroupCommentDto
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
                            ReactionCount = reactionsForComment.Count,
                            IsLikedByUser = userId != null && reactionsForComment.Any(r => r.IdUser == userId),
                            UserReaction = userId != null ? reactionsForComment
                                .Where(r => r.IdUser == userId)
                                .Select(r => r.Reaction)
                                .FirstOrDefault() : null
                        };
                    }).ToList(),
                IsLikedByUser = userId != null && postReactions.Any(r => r.IdUser == userId),
                UserReaction = userId != null ? postReactions
                    .Where(r => r.IdUser == userId)
                    .Select(r => r.Reaction)
                    .FirstOrDefault() : null
            };

            return Ok(postDto);
        }

        // POST: api/GroupPosts - Tạo post mới
        [HttpPost]
        public async Task<ActionResult<GroupPostDto>> CreatePost([FromBody] CreateGroupPostDto input)
        {
            // Kiểm tra group có tồn tại không
            var group = await _context.SocialGroups.FindAsync(input.IdGroup);
            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Kiểm tra user có quyền đăng bài không
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == input.IdGroup && m.IdUser == input.IdUser && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (userRole == null)
                return Forbid("Bạn không phải là thành viên của nhóm này");

            // Xác định trạng thái approval
            string approvalStatus = "approved"; // Mặc định là approved
            if (group.RequirePostApproval)
            {
                // Nếu group yêu cầu approval và user không phải admin/owner
                if (userRole != "admin" && userRole != "owner")
                {
                    approvalStatus = "pending";
                }
            }

            var post = new GroupPost
            {
                IdPost = Guid.NewGuid().ToString("N"),
                IdGroup = input.IdGroup,
                IdUser = input.IdUser,
                Content = input.Content,
                MediaUrl = input.MediaUrl,
                PostType = input.PostType,
                ApprovalStatus = approvalStatus,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            // Nếu post được approve ngay lập tức, set thông tin approval
            if (approvalStatus == "approved")
            {
                post.ApprovedBy = input.IdUser; // Tự approve
                post.ApprovedAt = DateTime.UtcNow;
            }

            _context.GroupPosts.Add(post);
            await _context.SaveChangesAsync();

            // Lấy thông tin user
            var user = await _context.Users.FindAsync(input.IdUser);

            var postDto = new GroupPostDto
            {
                IdPost = post.IdPost,
                IdGroup = post.IdGroup,
                IdUser = post.IdUser,
                UserName = user!.UserName,
                UserAvatar = user.AvatarUrl,
                Content = post.Content,
                MediaUrl = post.MediaUrl,
                PostType = post.PostType,
                ApprovalStatus = post.ApprovalStatus,
                ApprovedBy = post.ApprovedBy,
                ApprovedAt = post.ApprovedAt,
                CreatedAt = post.CreatedAt,
                UpdatedAt = post.UpdatedAt,
                CommentCount = 0,
                ReactionCount = 0,
                Reactions = new List<GroupReactionDto>(),
                Comments = new List<GroupCommentDto>(),
                IsLikedByUser = false,
                UserReaction = null
            };

            // Thêm thông báo về trạng thái approval
            var response = new
            {
                Post = postDto,
                Message = approvalStatus == "pending"
                    ? "Bài đăng đã được gửi và đang chờ duyệt từ admin/owner của nhóm"
                    : "Bài đăng đã được đăng thành công"
            };

            return CreatedAtAction(nameof(GetPost), new { id = post.IdPost }, response);
        }

        // PUT: api/GroupPosts/{id} - Cập nhật post
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePost(string id, [FromBody] UpdateGroupPostDto input, [FromQuery] string userId)
        {
            var post = await _context.GroupPosts.FindAsync(id);
            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Chỉ người đăng hoặc admin/owner mới được sửa
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == post.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (post.IdUser != userId && userRole != "admin" && userRole != "owner")
                return Forbid("Bạn không có quyền sửa bài đăng này");

            if (!string.IsNullOrEmpty(input.Content))
                post.Content = input.Content;
            if (input.MediaUrl != null)
                post.MediaUrl = input.MediaUrl;
            if (!string.IsNullOrEmpty(input.PostType))
                post.PostType = input.PostType;

            post.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/GroupPosts/{id} - Xóa post
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePost(string id, [FromQuery] string userId)
        {
            var post = await _context.GroupPosts.FindAsync(id);
            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Chỉ người đăng hoặc admin/owner mới được xóa
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == post.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (post.IdUser != userId && userRole != "admin" && userRole != "owner")
                return Forbid("Bạn không có quyền xóa bài đăng này");

            _context.GroupPosts.Remove(post);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // POST: api/GroupPosts/{id}/reaction - Thêm reaction
        [HttpPost("{id}/reaction")]
        public async Task<IActionResult> AddReaction(string id, [FromBody] CreateGroupReactionDto input, [FromQuery] string userId)
        {
            var post = await _context.GroupPosts.FindAsync(id);
            if (post == null)
                return NotFound("Không tìm thấy bài đăng");

            // Kiểm tra user có quyền xem post không
            var userRole = await _context.GroupMembers
                .Where(m => m.IdGroup == post.IdGroup && m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefaultAsync();

            if (userRole == null)
                return Forbid("Bạn không có quyền tương tác với bài đăng này");

            // Kiểm tra đã có reaction chưa
            var existingReaction = await _context.GroupReactions
                .FirstOrDefaultAsync(r => r.EntityType == "post" && r.EntityId == id && r.IdUser == userId);

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
                    EntityType = "post",
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

        // DELETE: api/GroupPosts/{id}/reaction - Xóa reaction
        [HttpDelete("{id}/reaction")]
        public async Task<IActionResult> RemoveReaction(string id, [FromQuery] string userId)
        {
            var reaction = await _context.GroupReactions
                .FirstOrDefaultAsync(r => r.EntityType == "post" && r.EntityId == id && r.IdUser == userId);

            if (reaction == null)
                return NotFound("Không tìm thấy reaction");

            _context.GroupReactions.Remove(reaction);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa reaction thành công" });
        }

        // GET: api/GroupPosts/{id}/reactions - Lấy danh sách reactions
        [HttpGet("{id}/reactions")]
        public async Task<ActionResult<IEnumerable<GroupReactionDto>>> GetPostReactions(string id)
        {
            var reactions = await _context.GroupReactions
                .Include(r => r.User)
                .Where(r => r.EntityType == "post" && r.EntityId == id)
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

        // GET: api/GroupPosts/pending/{groupId} - Lấy danh sách posts chờ duyệt
        [HttpGet("pending/{groupId}")]
        public async Task<ActionResult<IEnumerable<PendingPostDto>>> GetPendingPosts(
            string groupId,
            [FromQuery] string userId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                // Kiểm tra userId có hợp lệ không
                if (string.IsNullOrEmpty(userId))
                    return BadRequest("User ID không được để trống. Vui lòng đăng nhập.");

                // Kiểm tra user có quyền admin/owner không
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == groupId && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole != "admin" && userRole != "owner")
                    return Forbid("Bạn không có quyền xem bài đăng chờ duyệt");

                var pendingPosts = await _context.GroupPosts
                    .Where(p => p.IdGroup == groupId && p.ApprovalStatus == "pending")
                    .OrderByDescending(p => p.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                // Load users separately
                var userIds = pendingPosts.Select(p => p.IdUser).Distinct().ToList();
                var users = await _context.Users
                    .Where(u => userIds.Contains(u.IdUser))
                    .ToDictionaryAsync(u => u.IdUser, u => u!);

                // Load comments and reactions separately
                var postIds = pendingPosts.Select(p => p.IdPost).ToList();

                // Tạm thời bỏ qua counts để tránh lỗi SQL
                var comments = new Dictionary<string, int>();
                var reactions = new Dictionary<string, int>();

                var pendingPostDtos = pendingPosts.Select(p => new PendingPostDto
                {
                    IdPost = p.IdPost,
                    IdGroup = p.IdGroup,
                    IdUser = p.IdUser,
                    UserName = users.TryGetValue(p.IdUser, out var user) ? user.UserName : "Unknown",
                    UserAvatar = users.TryGetValue(p.IdUser, out var user2) ? user2.AvatarUrl : null,
                    Content = p.Content,
                    MediaUrl = p.MediaUrl,
                    PostType = p.PostType,
                    ApprovalStatus = p.ApprovalStatus,
                    CreatedAt = p.CreatedAt,
                    CommentCount = comments.TryGetValue(p.IdPost, out var commentCount) ? commentCount : 0,
                    ReactionCount = reactions.TryGetValue(p.IdPost, out var reactionCount) ? reactionCount : 0
                }).ToList();

                return Ok(pendingPostDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // POST: api/GroupPosts/approve - Duyệt bài đăng
        [HttpPost("approve")]
        public async Task<IActionResult> ApprovePost([FromBody] ApproveGroupPostDto input)
        {
            try
            {
                var post = await _context.GroupPosts.FindAsync(input.IdPost);
                if (post == null)
                    return NotFound("Không tìm thấy bài đăng");

                // Kiểm tra user có quyền duyệt không
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == post.IdGroup && m.IdUser == input.IdUser && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole != "admin" && userRole != "owner")
                    return Forbid("Bạn không có quyền duyệt bài đăng này");

                // Cập nhật trạng thái approval
                post.ApprovalStatus = input.ApprovalStatus;
                post.ApprovedBy = input.IdUser;
                post.ApprovedAt = DateTime.UtcNow;
                post.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                string message = input.ApprovalStatus == "approved" ? "Đã duyệt bài đăng thành công" : "Đã từ chối bài đăng";
                return Ok(new { message = message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/GroupPosts/stats/{groupId} - Thống kê posts trong group
        [HttpGet("stats/{groupId}")]
        public async Task<ActionResult<object>> GetGroupPostStats(string groupId, [FromQuery] string userId)
        {
            try
            {
                // Kiểm tra user có quyền xem thống kê không
                var userRole = await _context.GroupMembers
                    .Where(m => m.IdGroup == groupId && m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefaultAsync();

                if (userRole != "admin" && userRole != "owner")
                    return Forbid("Bạn không có quyền xem thống kê");

                var stats = await _context.GroupPosts
                    .Where(p => p.IdGroup == groupId)
                    .GroupBy(p => p.ApprovalStatus)
                    .Select(g => new { Status = g.Key, Count = g.Count() })
                    .ToListAsync();

                var totalPosts = await _context.GroupPosts
                    .Where(p => p.IdGroup == groupId)
                    .CountAsync();

                var pendingCount = stats.FirstOrDefault(s => s.Status == "pending")?.Count ?? 0;
                var approvedCount = stats.FirstOrDefault(s => s.Status == "approved")?.Count ?? 0;
                var rejectedCount = stats.FirstOrDefault(s => s.Status == "rejected")?.Count ?? 0;

                return Ok(new
                {
                    TotalPosts = totalPosts,
                    PendingPosts = pendingCount,
                    ApprovedPosts = approvedCount,
                    RejectedPosts = rejectedCount
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/GroupPosts/notifications/{userId} - Lấy thông báo cho user
        [HttpGet("notifications/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetUserNotifications(string userId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                // Lấy các bài đăng bị từ chối của user
                var rejectedPosts = await _context.GroupPosts
                    .Include(p => p.SocialGroup)
                    .Where(p => p.IdUser == userId && p.ApprovalStatus == "rejected")
                    .OrderByDescending(p => p.ApprovedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(p => new
                    {
                        IdPost = p.IdPost,
                        IdGroup = p.IdGroup,
                        GroupName = p.SocialGroup != null ? p.SocialGroup.GroupName : "Unknown Group",
                        Content = p.Content,
                        PostType = p.PostType,
                        CreatedAt = p.CreatedAt,
                        ApprovedAt = p.ApprovedAt,
                        ApprovedBy = p.ApprovedBy,
                        ApprovalStatus = p.ApprovalStatus
                    })
                    .ToListAsync();

                return Ok(rejectedPosts);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }
    }
}
