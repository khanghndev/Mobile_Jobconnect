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
    public class SocialGroupsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SocialGroupsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SocialGroups - Lấy danh sách tất cả groups
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GroupListItemDto>>> GetAllGroups([FromQuery] string? userId = null, [FromQuery] string? createdBy = null)
        {
            var query = _context.SocialGroups.AsQueryable();

            if (!string.IsNullOrEmpty(createdBy))
            {
                query = query.Where(g => g.CreatedBy == createdBy);
            }

            var groups = await query
                .OrderByDescending(g => g.CreatedAt)
                .Select(g => new GroupListItemDto
                {
                    IdGroup = g.IdGroup,
                    GroupName = g.GroupName,
                    Description = g.Description,
                    Privacy = g.Privacy,
                    CoverImageUrl = g.CoverImageUrl,
                    CreatorName = g.Creator!.UserName,
                    CreatedAt = g.CreatedAt,
                    MemberCount = g.GroupMembers.Count(m => m.Status == "active"),
                    PostCount = g.GroupPosts.Count(),
                    Tags = g.GroupTags.Select(t => t.TagName).ToList(),
                    UserRole = userId != null ? g.GroupMembers
                        .Where(m => m.IdUser == userId && m.Status == "active")
                        .Select(m => m.RoleInGroup)
                        .FirstOrDefault() : null,
                    UserStatus = userId != null ? g.GroupMembers
                        .Where(m => m.IdUser == userId)
                        .Select(m => m.Status)
                        .FirstOrDefault() : null
                })
                .ToListAsync();

            return Ok(groups);
        }

        // GET: api/SocialGroups/joined - Lấy danh sách groups mà user đã tham gia
        [HttpGet("joined")]
        public async Task<ActionResult<IEnumerable<GroupListItemDto>>> GetJoinedGroups([FromQuery] string userId)
        {
            if (string.IsNullOrEmpty(userId))
                return BadRequest("UserId is required");

            var groups = await _context.SocialGroups
                .Where(g => g.GroupMembers.Any(m => m.IdUser == userId && m.Status == "active"))
                .OrderByDescending(g => g.CreatedAt)
                .Select(g => new GroupListItemDto
                {
                    IdGroup = g.IdGroup,
                    GroupName = g.GroupName,
                    Description = g.Description,
                    Privacy = g.Privacy,
                    CoverImageUrl = g.CoverImageUrl,
                    CreatorName = g.Creator!.UserName,
                    CreatedAt = g.CreatedAt,
                    MemberCount = g.GroupMembers.Count(m => m.Status == "active"),
                    PostCount = g.GroupPosts.Count(),
                    Tags = g.GroupTags.Select(t => t.TagName).ToList(),
                    UserRole = g.GroupMembers
                        .Where(m => m.IdUser == userId && m.Status == "active")
                        .Select(m => m.RoleInGroup)
                        .FirstOrDefault(),
                    UserStatus = g.GroupMembers
                        .Where(m => m.IdUser == userId)
                        .Select(m => m.Status)
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(groups);
        }

        // GET: api/SocialGroups/search - Tìm kiếm groups
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<GroupListItemDto>>> SearchGroups(
            [FromQuery] string? keyword = null,
            [FromQuery] string? privacy = null,
            [FromQuery] string? sortBy = "newest",
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 12,
            [FromQuery] string? userId = null)
        {
            var query = _context.SocialGroups.AsQueryable();

            // Filter by keyword
            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(g => g.GroupName.Contains(keyword) ||
                                        (g.Description != null && g.Description.Contains(keyword)) ||
                                        g.GroupTags.Any(t => t.TagName.Contains(keyword)));
            }

            // Filter by privacy
            if (!string.IsNullOrEmpty(privacy))
            {
                query = query.Where(g => g.Privacy == privacy);
            }

            // Sort
            switch (sortBy.ToLower())
            {
                case "oldest":
                    query = query.OrderBy(g => g.CreatedAt);
                    break;
                case "name":
                    query = query.OrderBy(g => g.GroupName);
                    break;
                case "members":
                    query = query.OrderByDescending(g => g.GroupMembers.Count(m => m.Status == "active"));
                    break;
                default: // newest
                    query = query.OrderByDescending(g => g.CreatedAt);
                    break;
            }

            // Pagination
            var groups = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(g => new GroupListItemDto
                {
                    IdGroup = g.IdGroup,
                    GroupName = g.GroupName,
                    Description = g.Description,
                    Privacy = g.Privacy,
                    CoverImageUrl = g.CoverImageUrl,
                    CreatorName = g.Creator!.UserName,
                    CreatedAt = g.CreatedAt,
                    MemberCount = g.GroupMembers.Count(m => m.Status == "active"),
                    PostCount = g.GroupPosts.Count(),
                    Tags = g.GroupTags.Select(t => t.TagName).ToList(),
                    UserRole = userId != null ? g.GroupMembers
                        .Where(m => m.IdUser == userId && m.Status == "active")
                        .Select(m => m.RoleInGroup)
                        .FirstOrDefault() : null,
                    UserStatus = userId != null ? g.GroupMembers
                        .Where(m => m.IdUser == userId)
                        .Select(m => m.Status)
                        .FirstOrDefault() : null
                })
                .ToListAsync();

            return Ok(groups);
        }

        // GET: api/SocialGroups/{id} - Lấy thông tin chi tiết group
        [HttpGet("{id}")]
        public async Task<ActionResult<GroupInfoDto>> GetGroup(string id, [FromQuery] string? userId = null)
        {
            var group = await _context.SocialGroups
                .Include(g => g.Creator)
                .Include(g => g.GroupMembers)
                .Include(g => g.GroupPosts)
                .Include(g => g.GroupTags)
                .FirstOrDefaultAsync(g => g.IdGroup == id);

            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            var groupDto = new GroupInfoDto
            {
                IdGroup = group.IdGroup,
                GroupName = group.GroupName,
                Description = group.Description,
                Privacy = group.Privacy,
                CoverImageUrl = group.CoverImageUrl,
                CreatedBy = group.CreatedBy,
                CreatorName = group.Creator?.UserName,
                CreatorAvatar = group.Creator?.AvatarUrl,
                CreatedAt = group.CreatedAt,
                UpdatedAt = group.UpdatedAt,
                MemberCount = group.GroupMembers.Count(m => m.Status == "active"),
                PostCount = group.GroupPosts.Count(),
                Tags = group.GroupTags.Select(t => t.TagName).ToList(),
                UserRole = userId != null ? group.GroupMembers
                    .Where(m => m.IdUser == userId && m.Status == "active")
                    .Select(m => m.RoleInGroup)
                    .FirstOrDefault() : null,
                UserStatus = userId != null ? group.GroupMembers
                    .Where(m => m.IdUser == userId)
                    .Select(m => m.Status)
                    .FirstOrDefault() : null
            };

            return Ok(groupDto);
        }

        // POST: api/SocialGroups - Tạo group mới
        [HttpPost]
        public async Task<ActionResult<GroupInfoDto>> CreateGroup([FromBody] CreateGroupDto input)
        {
            // Kiểm tra user có tồn tại không
            var user = await _context.Users.FindAsync(input.CreatedBy);
            if (user == null)
                return BadRequest("Người dùng không tồn tại");

            var group = new SocialGroup
            {
                IdGroup = Guid.NewGuid().ToString("N"),
                GroupName = input.GroupName,
                Description = input.Description,
                Privacy = input.Privacy,
                CoverImageUrl = input.CoverImageUrl,
                CreatedBy = input.CreatedBy,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.SocialGroups.Add(group);

            // Thêm creator làm owner
            var ownerMember = new GroupMember
            {
                IdGroup = group.IdGroup,
                IdUser = input.CreatedBy,
                RoleInGroup = "owner",
                Status = "active",
                JoinedAt = DateTime.UtcNow
            };
            _context.GroupMembers.Add(ownerMember);

            // Thêm tags nếu có
            if (input.Tags != null && input.Tags.Any())
            {
                foreach (var tag in input.Tags)
                {
                    var groupTag = new GroupTag
                    {
                        IdGroup = group.IdGroup,
                        TagName = tag
                    };
                    _context.GroupTags.Add(groupTag);
                }
            }

            await _context.SaveChangesAsync();

            var groupDto = new GroupInfoDto
            {
                IdGroup = group.IdGroup,
                GroupName = group.GroupName,
                Description = group.Description,
                Privacy = group.Privacy,
                CoverImageUrl = group.CoverImageUrl,
                CreatedBy = group.CreatedBy,
                CreatorName = user.UserName,
                CreatorAvatar = user.AvatarUrl,
                CreatedAt = group.CreatedAt,
                UpdatedAt = group.UpdatedAt,
                MemberCount = 1,
                PostCount = 0,
                Tags = input.Tags ?? new List<string>(),
                UserRole = "owner",
                UserStatus = "active"
            };

            return CreatedAtAction(nameof(GetGroup), new { id = group.IdGroup }, groupDto);
        }

        // PUT: api/SocialGroups/{id} - Cập nhật group
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGroup(string id, [FromBody] UpdateGroupDto input, [FromQuery] string userId)
        {
            var group = await _context.SocialGroups
                .Include(g => g.GroupMembers)
                .FirstOrDefaultAsync(g => g.IdGroup == id);

            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Kiểm tra quyền: chỉ owner và admin mới được cập nhật
            var userRole = group.GroupMembers
                .Where(m => m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefault();

            if (userRole != "owner" && userRole != "admin")
                return Forbid("Bạn không có quyền cập nhật nhóm này");

            // Cập nhật thông tin
            if (!string.IsNullOrEmpty(input.GroupName))
                group.GroupName = input.GroupName;
            if (input.Description != null)
                group.Description = input.Description;
            if (!string.IsNullOrEmpty(input.Privacy))
                group.Privacy = input.Privacy;
            if (input.CoverImageUrl != null)
                group.CoverImageUrl = input.CoverImageUrl;

            group.UpdatedAt = DateTime.UtcNow;

            // Cập nhật tags
            if (input.Tags != null)
            {
                // Xóa tags cũ
                var existingTags = _context.GroupTags.Where(t => t.IdGroup == id);
                _context.GroupTags.RemoveRange(existingTags);

                // Thêm tags mới
                foreach (var tag in input.Tags)
                {
                    var groupTag = new GroupTag
                    {
                        IdGroup = group.IdGroup,
                        TagName = tag
                    };
                    _context.GroupTags.Add(groupTag);
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/SocialGroups/{id} - Xóa group
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGroup(string id, [FromQuery] string userId)
        {
            var group = await _context.SocialGroups
                .Include(g => g.GroupMembers)
                .FirstOrDefaultAsync(g => g.IdGroup == id);

            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Chỉ owner mới được xóa group
            var userRole = group.GroupMembers
                .Where(m => m.IdUser == userId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefault();

            if (userRole != "owner")
                return Forbid("Chỉ chủ sở hữu mới có thể xóa nhóm");

            _context.SocialGroups.Remove(group);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // POST: api/SocialGroups/{id}/join - Tham gia group
        [HttpPost("{id}/join")]
        public async Task<IActionResult> JoinGroup(string id, [FromQuery] string userId)
        {
            // Kiểm tra userId có hợp lệ không
            if (string.IsNullOrEmpty(userId))
                return BadRequest("User ID không được để trống. Vui lòng đăng nhập để tham gia nhóm.");

            var group = await _context.SocialGroups.FindAsync(id);
            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Kiểm tra user đã là member chưa
            var existingMember = await _context.GroupMembers
                .FirstOrDefaultAsync(m => m.IdGroup == id && m.IdUser == userId);

            if (existingMember != null)
            {
                if (existingMember.Status == "active")
                    return BadRequest("Bạn đã là thành viên của nhóm này");
                if (existingMember.Status == "pending")
                    return BadRequest("Yêu cầu tham gia của bạn đang chờ duyệt");
                if (existingMember.Status == "banned")
                    return BadRequest("Bạn đã bị cấm khỏi nhóm này");
            }

            // Tạo request tham gia
            var member = new GroupMember
            {
                IdGroup = id,
                IdUser = userId,
                RoleInGroup = "member",
                Status = group.Privacy == "public" ? "active" : "pending",
                JoinedAt = DateTime.UtcNow
            };

            _context.GroupMembers.Add(member);
            await _context.SaveChangesAsync();

            return Ok(new { message = group.Privacy == "public" ? "Đã tham gia nhóm thành công" : "Yêu cầu tham gia đã được gửi" });
        }

        // POST: api/SocialGroups/{id}/leave - Rời khỏi group
        [HttpPost("{id}/leave")]
        public async Task<IActionResult> LeaveGroup(string id, [FromQuery] string userId)
        {
            var member = await _context.GroupMembers
                .FirstOrDefaultAsync(m => m.IdGroup == id && m.IdUser == userId);

            if (member == null)
                return NotFound("Bạn không phải là thành viên của nhóm này");

            if (member.RoleInGroup == "owner")
                return BadRequest("Chủ sở hữu không thể rời khỏi nhóm. Hãy chuyển quyền sở hữu hoặc xóa nhóm.");

            _context.GroupMembers.Remove(member);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã rời khỏi nhóm thành công" });
        }

        // GET: api/SocialGroups/{id}/members - Lấy danh sách members
        [HttpGet("{id}/members")]
        public async Task<ActionResult<IEnumerable<GroupMemberDto>>> GetGroupMembers(string id)
        {
            var members = await _context.GroupMembers
                .Include(m => m.User)
                .Where(m => m.IdGroup == id && m.Status == "active")
                .OrderBy(m => m.RoleInGroup)
                .ThenBy(m => m.JoinedAt)
                .Select(m => new GroupMemberDto
                {
                    IdUser = m.IdUser,
                    UserName = m.User!.UserName,
                    Email = m.User.Email,
                    AvatarUrl = m.User.AvatarUrl,
                    RoleInGroup = m.RoleInGroup,
                    Status = m.Status,
                    JoinedAt = m.JoinedAt
                })
                .ToListAsync();

            return Ok(members);
        }

        // PUT: api/SocialGroups/{id}/members/role - Thay đổi vai trò member
        [HttpPut("{id}/members/role")]
        public async Task<IActionResult> ChangeMemberRole(string id, [FromBody] ChangeMemberRoleDto input, [FromQuery] string currentUserId)
        {
            var group = await _context.SocialGroups
                .Include(g => g.GroupMembers)
                .FirstOrDefaultAsync(g => g.IdGroup == id);

            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Kiểm tra quyền: chỉ owner và admin mới được thay đổi role
            var currentUserRole = group.GroupMembers
                .Where(m => m.IdUser == currentUserId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefault();

            if (currentUserRole != "owner" && currentUserRole != "admin")
                return Forbid("Bạn không có quyền thay đổi vai trò thành viên");

            // Không thể thay đổi role của owner
            if (input.RoleInGroup == "owner" && currentUserRole != "owner")
                return Forbid("Chỉ chủ sở hữu mới có thể chuyển quyền sở hữu");

            var member = await _context.GroupMembers
                .FirstOrDefaultAsync(m => m.IdGroup == id && m.IdUser == input.IdUser);

            if (member == null)
                return NotFound("Không tìm thấy thành viên");

            member.RoleInGroup = input.RoleInGroup;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã thay đổi vai trò thành viên thành công" });
        }

        // DELETE: api/SocialGroups/{id}/members/{userId} - Kick member
        [HttpDelete("{id}/members/{userId}")]
        public async Task<IActionResult> KickMember(string id, string userId, [FromQuery] string currentUserId)
        {
            var group = await _context.SocialGroups
                .Include(g => g.GroupMembers)
                .FirstOrDefaultAsync(g => g.IdGroup == id);

            if (group == null)
                return NotFound("Không tìm thấy nhóm");

            // Kiểm tra quyền: chỉ owner và admin mới được kick member
            var currentUserRole = group.GroupMembers
                .Where(m => m.IdUser == currentUserId && m.Status == "active")
                .Select(m => m.RoleInGroup)
                .FirstOrDefault();

            if (currentUserRole != "owner" && currentUserRole != "admin")
                return Forbid("Bạn không có quyền loại bỏ thành viên");

            // Không thể kick owner
            var targetMember = await _context.GroupMembers
                .FirstOrDefaultAsync(m => m.IdGroup == id && m.IdUser == userId);

            if (targetMember == null)
                return NotFound("Không tìm thấy thành viên");

            if (targetMember.RoleInGroup == "owner")
                return Forbid("Không thể loại bỏ chủ sở hữu");

            _context.GroupMembers.Remove(targetMember);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã loại bỏ thành viên khỏi nhóm" });
        }

        // GET: api/SocialGroups/tags - Lấy danh sách tags phổ biến
        [HttpGet("tags")]
        public async Task<ActionResult<IEnumerable<string>>> GetPopularTags()
        {
            var tags = await _context.GroupTags
                .GroupBy(t => t.TagName)
                .OrderByDescending(g => g.Count())
                .Take(20)
                .Select(g => g.Key)
                .ToListAsync();

            return Ok(tags);
        }

        // GET: api/SocialGroups/stats - Lấy thống kê groups của user
        [HttpGet("stats")]
        public async Task<ActionResult<object>> GetUserStats([FromQuery] string userId)
        {
            if (string.IsNullOrEmpty(userId))
                return BadRequest("UserId is required");

            var totalGroups = await _context.SocialGroups.CountAsync();
            var joinedGroups = await _context.GroupMembers
                .CountAsync(m => m.IdUser == userId && m.Status == "active");
            var createdGroups = await _context.SocialGroups
                .CountAsync(g => g.CreatedBy == userId);

            return Ok(new
            {
                totalGroups,
                joinedGroups,
                createdGroups
            });
        }
    }
}
