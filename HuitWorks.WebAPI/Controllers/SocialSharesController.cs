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
    public class SocialSharesController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SocialSharesController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SocialShares/post/{idPost}
        [HttpGet("post/{idPost}")]
        public async Task<ActionResult<IEnumerable<SocialShareDto>>> GetByPost(string idPost)
        {
            var shares = await _context.SocialShares
                .Include(s => s.User)
                .Include(s => s.Group)
                .Where(s => s.IdPost == idPost)
                .OrderByDescending(s => s.SharedAt)
                .ToListAsync();

            var result = shares.Select(s => new SocialShareDto
            {
                IdShare = s.IdShare,
                IdPost = s.IdPost,
                IdUser = s.IdUser,
                UserName = s.User?.UserName,
                AvatarUrl = s.User?.AvatarUrl,
                ShareType = s.ShareType,
                SharedWithGroup = s.SharedWithGroup,
                GroupName = s.Group?.GroupName,
                SharedAt = s.SharedAt
            }).ToList();

            return Ok(result);
        }

        // GET: api/SocialShares/count/{idPost}
        [HttpGet("count/{idPost}")]
        public async Task<ActionResult<int>> GetShareCount(string idPost)
        {
            var count = await _context.SocialShares
                .Where(s => s.IdPost == idPost)
                .CountAsync();

            return Ok(count);
        }

        // POST: api/SocialShares
        [HttpPost]
        public async Task<ActionResult<SocialShareDto>> CreateShare([FromBody] CreateShareDto input)
        {
            var share = new SocialShare
            {
                IdShare = Guid.NewGuid().ToString("N"),
                IdPost = input.IdPost,
                IdUser = input.IdUser,
                ShareType = input.ShareType,
                SharedWithGroup = input.SharedWithGroup,
                SharedAt = DateTime.UtcNow
            };

            _context.SocialShares.Add(share);
            await _context.SaveChangesAsync();

            var user = await _context.Users.FindAsync(input.IdUser);
            SocialGroup? group = null;
            if (!string.IsNullOrEmpty(input.SharedWithGroup))
            {
                group = await _context.SocialGroups.FindAsync(input.SharedWithGroup);
            }

            return CreatedAtAction(nameof(GetByPost), new { idPost = share.IdPost }, new SocialShareDto
            {
                IdShare = share.IdShare,
                IdPost = share.IdPost,
                IdUser = share.IdUser,
                UserName = user?.UserName,
                AvatarUrl = user?.AvatarUrl,
                ShareType = share.ShareType,
                SharedWithGroup = share.SharedWithGroup,
                GroupName = group?.GroupName,
                SharedAt = share.SharedAt
            });
        }

        // DELETE: api/SocialShares/{idShare}
        [HttpDelete("{idShare}")]
        public async Task<IActionResult> DeleteShare(string idShare)
        {
            var share = await _context.SocialShares.FindAsync(idShare);
            if (share == null) return NotFound();

            _context.SocialShares.Remove(share);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

