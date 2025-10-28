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
    public class SocialFollowsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SocialFollowsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SocialFollows/followers/{userId}
        [HttpGet("followers/{userId}")]
        public async Task<ActionResult<IEnumerable<SocialFollowDto>>> GetFollowers(string userId)
        {
            var followers = await _context.SocialFollows
                .Include(sf => sf.Follower)
                .Include(sf => sf.Following)
                .Where(sf => sf.FollowingId == userId)
                .OrderByDescending(sf => sf.CreatedAt)
                .ToListAsync();

            var result = followers.Select(sf => new SocialFollowDto
            {
                FollowerId = sf.FollowerId,
                FollowingId = sf.FollowingId,
                FollowerName = sf.Follower?.UserName,
                FollowerAvatar = sf.Follower?.AvatarUrl,
                FollowingName = sf.Following?.UserName,
                FollowingAvatar = sf.Following?.AvatarUrl,
                FollowType = sf.FollowType,
                CreatedAt = sf.CreatedAt
            }).ToList();

            return Ok(result);
        }

        // GET: api/SocialFollows/following/{userId}
        [HttpGet("following/{userId}")]
        public async Task<ActionResult<IEnumerable<SocialFollowDto>>> GetFollowing(string userId)
        {
            var following = await _context.SocialFollows
                .Include(sf => sf.Follower)
                .Include(sf => sf.Following)
                .Where(sf => sf.FollowerId == userId)
                .OrderByDescending(sf => sf.CreatedAt)
                .ToListAsync();

            var result = following.Select(sf => new SocialFollowDto
            {
                FollowerId = sf.FollowerId,
                FollowingId = sf.FollowingId,
                FollowerName = sf.Follower?.UserName,
                FollowerAvatar = sf.Follower?.AvatarUrl,
                FollowingName = sf.Following?.UserName,
                FollowingAvatar = sf.Following?.AvatarUrl,
                FollowType = sf.FollowType,
                CreatedAt = sf.CreatedAt
            }).ToList();

            return Ok(result);
        }

        // GET: api/SocialFollows/stats/{userId}
        [HttpGet("stats/{userId}")]
        public async Task<ActionResult<FollowStatsDto>> GetStats(string userId, [FromQuery] string? currentUserId = null)
        {
            var followersCount = await _context.SocialFollows
                .Where(sf => sf.FollowingId == userId)
                .CountAsync();

            var followingCount = await _context.SocialFollows
                .Where(sf => sf.FollowerId == userId)
                .CountAsync();

            bool isFollowing = false;
            bool isFollowedBy = false;

            if (!string.IsNullOrEmpty(currentUserId))
            {
                isFollowing = await _context.SocialFollows
                    .AnyAsync(sf => sf.FollowerId == currentUserId && sf.FollowingId == userId);

                isFollowedBy = await _context.SocialFollows
                    .AnyAsync(sf => sf.FollowerId == userId && sf.FollowingId == currentUserId);
            }

            return Ok(new FollowStatsDto
            {
                FollowersCount = followersCount,
                FollowingCount = followingCount,
                IsFollowing = isFollowing,
                IsFollowedBy = isFollowedBy
            });
        }

        // POST: api/SocialFollows
        [HttpPost]
        public async Task<ActionResult<SocialFollowDto>> CreateFollow([FromBody] CreateFollowDto input)
        {
            if (input.FollowerId == input.FollowingId)
            {
                return BadRequest("Không thể theo dõi chính mình.");
            }

            var existing = await _context.SocialFollows
                .FirstOrDefaultAsync(sf => sf.FollowerId == input.FollowerId && sf.FollowingId == input.FollowingId);

            if (existing != null)
            {
                return Conflict("Đã theo dõi người này.");
            }

            var follow = new SocialFollow
            {
                FollowerId = input.FollowerId,
                FollowingId = input.FollowingId,
                FollowType = input.FollowType,
                CreatedAt = DateTime.UtcNow
            };

            _context.SocialFollows.Add(follow);
            await _context.SaveChangesAsync();

            var follower = await _context.Users.FindAsync(input.FollowerId);
            var following = await _context.Users.FindAsync(input.FollowingId);

            return CreatedAtAction(nameof(GetFollowing), new { userId = input.FollowerId }, new SocialFollowDto
            {
                FollowerId = follow.FollowerId,
                FollowingId = follow.FollowingId,
                FollowerName = follower?.UserName,
                FollowerAvatar = follower?.AvatarUrl,
                FollowingName = following?.UserName,
                FollowingAvatar = following?.AvatarUrl,
                FollowType = follow.FollowType,
                CreatedAt = follow.CreatedAt
            });
        }

        // DELETE: api/SocialFollows
        [HttpDelete]
        public async Task<IActionResult> Unfollow([FromQuery] string followerId, [FromQuery] string followingId)
        {
            var follow = await _context.SocialFollows
                .FirstOrDefaultAsync(sf => sf.FollowerId == followerId && sf.FollowingId == followingId);

            if (follow == null) return NotFound();

            _context.SocialFollows.Remove(follow);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

