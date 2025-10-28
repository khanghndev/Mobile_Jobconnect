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
    public class SocialReactionsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SocialReactionsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SocialReactions/post/{idPost}
        [HttpGet("post/{idPost}")]
        public async Task<ActionResult<IEnumerable<SocialReactionDto>>> GetByPost(string idPost)
        {
            var reactions = await _context.SocialReactions
                .Include(r => r.User)
                .Where(r => r.IdPost == idPost)
                .OrderBy(r => r.CreatedAt)
                .ToListAsync();

            var result = reactions.Select(r => new SocialReactionDto
            {
                IdReaction = r.IdReaction,
                IdPost = r.IdPost,
                IdUser = r.IdUser,
                UserName = r.User?.UserName,
                AvatarUrl = r.User?.AvatarUrl,
                ReactionType = r.ReactionType,
                CreatedAt = r.CreatedAt
            }).ToList();

            return Ok(result);
        }

        // GET: api/SocialReactions/post/{idPost}/summary
        [HttpGet("post/{idPost}/summary")]
        public async Task<ActionResult<Dictionary<string, int>>> GetReactionSummary(string idPost)
        {
            var summary = await _context.SocialReactions
                .Where(r => r.IdPost == idPost)
                .GroupBy(r => r.ReactionType)
                .Select(g => new { ReactionType = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.ReactionType, x => x.Count);

            return Ok(summary);
        }

        // GET: api/SocialReactions/post/{idPost}/users
        [HttpGet("post/{idPost}/users")]
        public async Task<ActionResult<List<string>>> GetUserReactions(string idPost)
        {
            var userIds = await _context.SocialReactions
                .Where(r => r.IdPost == idPost)
                .Select(r => r.IdUser)
                .Distinct()
                .ToListAsync();

            return Ok(userIds);
        }

        // POST: api/SocialReactions
        [HttpPost]
        public async Task<ActionResult<SocialReactionDto>> CreateReaction([FromBody] CreateReactionDto input)
        {
            // Check if user already reacted
            var existing = await _context.SocialReactions
                .FirstOrDefaultAsync(r => r.IdPost == input.IdPost && r.IdUser == input.IdUser);

            if (existing != null)
            {
                // Update reaction if different type
                if (existing.ReactionType != input.ReactionType)
                {
                    existing.ReactionType = input.ReactionType;
                    existing.CreatedAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();

                    var user = await _context.Users.FindAsync(input.IdUser);
                    return Ok(new SocialReactionDto
                    {
                        IdReaction = existing.IdReaction,
                        IdPost = existing.IdPost,
                        IdUser = existing.IdUser,
                        UserName = user?.UserName,
                        AvatarUrl = user?.AvatarUrl,
                        ReactionType = existing.ReactionType,
                        CreatedAt = existing.CreatedAt
                    });
                }
                // If same reaction, delete it (toggle)
                _context.SocialReactions.Remove(existing);
                await _context.SaveChangesAsync();
                return Ok();
            }

            // Create new reaction
            var reaction = new SocialReaction
            {
                IdReaction = Guid.NewGuid().ToString("N"),
                IdPost = input.IdPost,
                IdUser = input.IdUser,
                ReactionType = input.ReactionType,
                CreatedAt = DateTime.UtcNow
            };

            _context.SocialReactions.Add(reaction);
            await _context.SaveChangesAsync();

            var reactionUser = await _context.Users.FindAsync(input.IdUser);
            return CreatedAtAction(nameof(GetByPost), new { idPost = reaction.IdPost }, new SocialReactionDto
            {
                IdReaction = reaction.IdReaction,
                IdPost = reaction.IdPost,
                IdUser = reaction.IdUser,
                UserName = reactionUser?.UserName,
                AvatarUrl = reactionUser?.AvatarUrl,
                ReactionType = reaction.ReactionType,
                CreatedAt = reaction.CreatedAt
            });
        }

        // DELETE: api/SocialReactions
        [HttpDelete]
        public async Task<IActionResult> DeleteReaction([FromQuery] string idPost, [FromQuery] string idUser)
        {
            var reaction = await _context.SocialReactions
                .FirstOrDefaultAsync(r => r.IdPost == idPost && r.IdUser == idUser);

            if (reaction == null) return NotFound();

            _context.SocialReactions.Remove(reaction);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

