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
    public class SocialPostsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SocialPostsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<SocialPostDto>>> GetAll([FromQuery] string? userId = null, [FromQuery] string? currentUserId = null, [FromQuery] string? postType = null)
        {
            var query = _context.SocialPosts.AsQueryable();
            if (!string.IsNullOrEmpty(userId))
            {
                query = query.Where(p => p.IdUser == userId);
            }
            if (!string.IsNullOrEmpty(postType))
            {
                query = query.Where(p => p.PostType == postType);
            }

            var posts = await query
                .Include(p => p.User)
                .Include(p => p.Group)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();

            var list = new List<SocialPostDto>();

            foreach (var p in posts)
            {
                // Get reactions summary
                var reactionsSummary = await _context.SocialReactions
                    .Where(r => r.IdPost == p.IdPost)
                    .GroupBy(r => r.ReactionType)
                    .Select(g => new { Type = g.Key, Count = g.Count() })
                    .ToDictionaryAsync(x => x.Type, x => x.Count);

                // Get current user reaction if exists
                string? currentUserReaction = null;
                if (!string.IsNullOrEmpty(currentUserId))
                {
                    var userReaction = await _context.SocialReactions
                        .FirstOrDefaultAsync(r => r.IdPost == p.IdPost && r.IdUser == currentUserId);
                    currentUserReaction = userReaction?.ReactionType;
                }

                // Check if current user saved this post
                bool isSaved = false;
                if (!string.IsNullOrEmpty(currentUserId))
                {
                    isSaved = await _context.SavedPosts
                        .AnyAsync(sp => sp.IdPost == p.IdPost && sp.IdUser == currentUserId);
                }

                var dto = new SocialPostDto
                {
                    IdPost = p.IdPost,
                    IdUser = p.IdUser,
                    UserName = p.User?.UserName ?? "Unknown",
                    AvatarUrl = p.User?.AvatarUrl,
                    IdGroup = p.IdGroup,
                    GroupName = p.Group?.GroupName,
                    Content = p.Content,
                    ImageUrl = p.ImageUrl,
                    VideoUrl = p.VideoUrl,
                    Visibility = p.Visibility,
                    PostType = p.PostType,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    LikesCount = await _context.SocialReactions.CountAsync(l => l.IdPost == p.IdPost),
                    CommentsCount = await _context.SocialComments.CountAsync(c => c.IdPost == p.IdPost),
                    SharesCount = await _context.SocialShares.CountAsync(s => s.IdPost == p.IdPost),
                    IsSaved = isSaved,
                    ReactionsSummary = reactionsSummary,
                    CurrentUserReaction = currentUserReaction
                };

                // hashtags
                var tags = await (from ph in _context.SocialPostHashtags
                                  join h in _context.Hashtags on ph.IdHashtag equals h.IdHashtag
                                  where ph.IdPost == p.IdPost
                                  select h.TagOriginal).ToListAsync();
                dto.Hashtags = tags;

                list.Add(dto);
            }

            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SocialPostDto>> GetById(string id)
        {
            var p = await _context.SocialPosts
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.IdPost == id);
            if (p == null) return NotFound();

            var dto = new SocialPostDto
            {
                IdPost = p.IdPost,
                IdUser = p.IdUser,
                UserName = p.User?.UserName ?? "Unknown",
                AvatarUrl = p.User?.AvatarUrl,
                Content = p.Content,
                ImageUrl = p.ImageUrl,
                VideoUrl = p.VideoUrl,
                Visibility = p.Visibility,
                PostType = p.PostType,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt,
                LikesCount = await _context.SocialReactions.CountAsync(l => l.IdPost == p.IdPost),
                CommentsCount = await _context.SocialComments.CountAsync(c => c.IdPost == p.IdPost)
            };
            dto.Hashtags = await (from ph in _context.SocialPostHashtags
                                  join h in _context.Hashtags on ph.IdHashtag equals h.IdHashtag
                                  where ph.IdPost == p.IdPost
                                  select h.TagOriginal).ToListAsync();
            return Ok(dto);
        }

        [HttpPost]
        public async Task<ActionResult<SocialPostDto>> Create([FromBody] CreateSocialPostDto input)
        {
            var entity = new SocialPost
            {
                IdPost = Guid.NewGuid().ToString("N"),
                IdUser = input.IdUser,
                IdGroup = input.IdGroup,
                Content = input.Content,
                ImageUrl = input.ImageUrl,
                VideoUrl = input.VideoUrl,
                Visibility = input.Visibility,
                PostType = input.PostType,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.SocialPosts.Add(entity);
            await _context.SaveChangesAsync();

            // upsert hashtags if provided
            if (input.Hashtags != null && input.Hashtags.Count > 0)
            {
                foreach (var raw in input.Hashtags)
                {
                    var tagOriginal = raw?.Trim();
                    if (string.IsNullOrWhiteSpace(tagOriginal)) continue;
                    if (!tagOriginal.StartsWith("#")) tagOriginal = "#" + tagOriginal;
                    var slug = new string(tagOriginal.TrimStart('#').ToLowerInvariant()
                        .Where(ch => char.IsLetterOrDigit(ch) || ch == '_' || ch == '-').ToArray());
                    if (string.IsNullOrWhiteSpace(slug)) continue;

                    var ht = await _context.Hashtags.FirstOrDefaultAsync(h => h.Slug == slug);
                    if (ht == null)
                    {
                        ht = new Hashtag { TagOriginal = tagOriginal, Slug = slug, CreatedAt = DateTime.UtcNow };
                        _context.Hashtags.Add(ht);
                        await _context.SaveChangesAsync();
                    }
                    // link
                    if (!await _context.SocialPostHashtags.AnyAsync(x => x.IdPost == entity.IdPost && x.IdHashtag == ht.IdHashtag))
                    {
                        _context.SocialPostHashtags.Add(new SocialPostHashtag { IdPost = entity.IdPost, IdHashtag = ht.IdHashtag });
                    }
                }
                await _context.SaveChangesAsync();
            }

            var user = await _context.Users.FindAsync(entity.IdUser);
            var group = entity.IdGroup != null ? await _context.SocialGroups.FindAsync(entity.IdGroup) : null;

            return CreatedAtAction(nameof(GetById), new { id = entity.IdPost }, new SocialPostDto
            {
                IdPost = entity.IdPost,
                IdUser = entity.IdUser,
                UserName = user?.UserName ?? "Unknown",
                AvatarUrl = user?.AvatarUrl,
                IdGroup = entity.IdGroup,
                GroupName = group?.GroupName,
                Content = entity.Content,
                ImageUrl = entity.ImageUrl,
                VideoUrl = entity.VideoUrl,
                Visibility = entity.Visibility,
                PostType = entity.PostType,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                LikesCount = 0,
                CommentsCount = 0,
                SharesCount = 0,
                IsSaved = false,
                Hashtags = await (from ph in _context.SocialPostHashtags
                                   join h in _context.Hashtags on ph.IdHashtag equals h.IdHashtag
                                   where ph.IdPost == entity.IdPost
                                   select h.TagOriginal).ToListAsync()
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateSocialPostDto input)
        {
            var entity = await _context.SocialPosts.FindAsync(id);
            if (entity == null) return NotFound();

            entity.Content = input.Content;
            entity.ImageUrl = input.ImageUrl;
            entity.VideoUrl = input.VideoUrl;
            entity.Visibility = input.Visibility;
            entity.PostType = input.PostType;
            entity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Update hashtags: simple replace strategy
            if (input.Hashtags != null)
            {
                var oldLinks = _context.SocialPostHashtags.Where(x => x.IdPost == id);
                _context.SocialPostHashtags.RemoveRange(oldLinks);
                await _context.SaveChangesAsync();

                foreach (var raw in input.Hashtags)
                {
                    var tagOriginal = raw?.Trim();
                    if (string.IsNullOrWhiteSpace(tagOriginal)) continue;
                    if (!tagOriginal.StartsWith("#")) tagOriginal = "#" + tagOriginal;
                    var slug = new string(tagOriginal.TrimStart('#').ToLowerInvariant()
                        .Where(ch => char.IsLetterOrDigit(ch) || ch == '_' || ch == '-').ToArray());
                    if (string.IsNullOrWhiteSpace(slug)) continue;

                    var ht = await _context.Hashtags.FirstOrDefaultAsync(h => h.Slug == slug);
                    if (ht == null)
                    {
                        ht = new Hashtag { TagOriginal = tagOriginal, Slug = slug, CreatedAt = DateTime.UtcNow };
                        _context.Hashtags.Add(ht);
                        await _context.SaveChangesAsync();
                    }
                    _context.SocialPostHashtags.Add(new SocialPostHashtag { IdPost = id, IdHashtag = ht.IdHashtag });
                }
                await _context.SaveChangesAsync();
            }
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.SocialPosts.FindAsync(id);
            if (entity == null) return NotFound();
            _context.SocialPosts.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPost("{id}/like")]
        public async Task<IActionResult> LikePost(string id, [FromQuery] string userId)
        {
            var exists = await _context.SocialReactions
                .FirstOrDefaultAsync(r => r.IdPost == id && r.IdUser == userId);
            
            if (exists != null) 
            {
                // Toggle - remove if already liked
                _context.SocialReactions.Remove(exists);
                await _context.SaveChangesAsync();
                return Ok();
            }
            
            _context.SocialReactions.Add(new SocialReaction
            {
                IdReaction = Guid.NewGuid().ToString("N"),
                IdPost = id,
                IdUser = userId,
                ReactionType = "like",
                CreatedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpDelete("{id}/like")]
        public async Task<IActionResult> UnlikePost(string id, [FromQuery] string userId)
        {
            var like = await _context.SocialReactions
                .FirstOrDefaultAsync(r => r.IdPost == id && r.IdUser == userId);
            
            if (like == null) return NotFound();
            
            _context.SocialReactions.Remove(like);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("{id}/likes")]
        public async Task<ActionResult<IEnumerable<string>>> GetLikes(string id)
        {
            var ids = await _context.SocialReactions
                .Where(l => l.IdPost == id)
                .Select(l => l.IdUser)
                .Distinct()
                .ToListAsync();
            return Ok(ids);
        }

        [HttpPost("react")]
        public async Task<IActionResult> ReactToPost([FromBody] ReactToPostDto input)
        {
            try
            {
                // Validation
                if (string.IsNullOrEmpty(input.PostId) || string.IsNullOrEmpty(input.UserId) || string.IsNullOrEmpty(input.ReactionType))
                {
                    return BadRequest(new { message = "Thiếu thông tin bắt buộc" });
                }

                // Kiểm tra post có tồn tại không
                var post = await _context.SocialPosts.FindAsync(input.PostId);
                if (post == null)
                {
                    return BadRequest(new { message = "Bài đăng không tồn tại" });
                }

                // Kiểm tra user có tồn tại không
                var user = await _context.Users.FindAsync(input.UserId);
                if (user == null)
                {
                    return BadRequest(new { message = "Người dùng không tồn tại" });
                }

                // Kiểm tra xem user đã có reaction cho post này chưa
                var existingReaction = await _context.SocialReactions
                    .FirstOrDefaultAsync(r => r.IdPost == input.PostId && r.IdUser == input.UserId);

                if (existingReaction != null)
                {
                    if (existingReaction.ReactionType == input.ReactionType)
                    {
                        // Nếu cùng loại reaction thì bỏ reaction (toggle off)
                        _context.SocialReactions.Remove(existingReaction);
                        await _context.SaveChangesAsync();
                        return Ok(new { 
                            message = "Đã bỏ cảm xúc", 
                            isReacted = false, 
                            reactionType = (string?)null,
                            reactionsCount = await _context.SocialReactions.CountAsync(r => r.IdPost == input.PostId)
                        });
                    }
                    else
                    {
                        // Nếu khác loại reaction thì cập nhật
                        existingReaction.ReactionType = input.ReactionType;
                        await _context.SaveChangesAsync();
                        return Ok(new { 
                            message = "Đã cập nhật cảm xúc", 
                            isReacted = true, 
                            reactionType = input.ReactionType,
                            reactionsCount = await _context.SocialReactions.CountAsync(r => r.IdPost == input.PostId)
                        });
                    }
                }
                else
                {
                    // Tạo reaction mới
                    var reaction = new SocialReaction
                    {
                        IdReaction = Guid.NewGuid().ToString("N"),
                        IdPost = input.PostId,
                        IdUser = input.UserId,
                        ReactionType = input.ReactionType,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.SocialReactions.Add(reaction);
                    await _context.SaveChangesAsync();
                    return Ok(new { 
                        message = "Đã thêm cảm xúc", 
                        isReacted = true, 
                        reactionType = input.ReactionType,
                        reactionsCount = await _context.SocialReactions.CountAsync(r => r.IdPost == input.PostId)
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Có lỗi xảy ra khi xử lý cảm xúc", error = ex.Message });
            }
        }

        [HttpGet("{id}/reactions")]
        public async Task<ActionResult<PostReactionsDto>> GetPostReactions(string id, [FromQuery] string? userId = null)
        {
            try
            {
                // Lấy tất cả reactions của post
                var reactions = await _context.SocialReactions
                    .Where(r => r.IdPost == id)
                    .Include(r => r.User)
                    .ToListAsync();

                // Nhóm theo loại reaction
                var reactionsByType = reactions
                    .GroupBy(r => r.ReactionType)
                    .ToDictionary(g => g.Key, g => g.Count());

                // Lấy reaction của user hiện tại (nếu có)
                string? currentUserReaction = null;
                if (!string.IsNullOrEmpty(userId))
                {
                    var userReaction = reactions.FirstOrDefault(r => r.IdUser == userId);
                    currentUserReaction = userReaction?.ReactionType;
                }

                var result = new PostReactionsDto
                {
                    PostId = id,
                    ReactionsByType = reactionsByType,
                    CurrentUserReaction = currentUserReaction,
                    TotalReactions = reactions.Count
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Có lỗi xảy ra khi lấy thông tin cảm xúc", error = ex.Message });
            }
        }

        // Simple feed: public posts + friends-only posts from accepted connections
        [HttpGet("feed/{userId}")]
        public async Task<ActionResult<IEnumerable<SocialPostDto>>> GetFeed(string userId)
        {
            var friends = await _context.SocialConnections
                .Where(c => c.Status == "accepted" && (c.IdUser1 == userId || c.IdUser2 == userId))
                .Select(c => c.IdUser1 == userId ? c.IdUser2 : c.IdUser1)
                .ToListAsync();

            var feedPosts = await _context.SocialPosts
                .Include(p => p.User)
                .Where(p => p.Visibility == "public" ||
                            (p.Visibility == "friends" && (p.IdUser == userId || friends.Contains(p.IdUser))) ||
                            (p.Visibility == "private" && p.IdUser == userId))
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();

            var feed = feedPosts.Select(p => new SocialPostDto
            {
                IdPost = p.IdPost,
                IdUser = p.IdUser,
                UserName = p.User?.UserName ?? "Unknown",
                AvatarUrl = p.User?.AvatarUrl,
                Content = p.Content,
                ImageUrl = p.ImageUrl,
                VideoUrl = p.VideoUrl,
                Visibility = p.Visibility,
                PostType = p.PostType,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt,
                LikesCount = _context.SocialReactions.Count(l => l.IdPost == p.IdPost),
                CommentsCount = _context.SocialComments.Count(c => c.IdPost == p.IdPost)
            }).ToList();

            // load hashtags for feed items
            foreach (var item in feed)
            {
                item.Hashtags = (from ph in _context.SocialPostHashtags
                                 join h in _context.Hashtags on ph.IdHashtag equals h.IdHashtag
                                 where ph.IdPost == item.IdPost
                                 select h.TagOriginal).ToList();
            }

            return Ok(feed);
        }
    }
}


