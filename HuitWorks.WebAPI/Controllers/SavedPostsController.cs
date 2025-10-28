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
    public class SavedPostsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SavedPostsController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/SavedPosts/user/{idUser}
        [HttpGet("user/{idUser}")]
        public async Task<ActionResult<IEnumerable<SavedPostDto>>> GetSavedPosts(string idUser, [FromQuery] string? folderName = null)
        {
            var query = _context.SavedPosts
                .Include(sp => sp.Post)
                    .ThenInclude(p => p!.User)
                .Where(sp => sp.IdUser == idUser);

            if (!string.IsNullOrEmpty(folderName))
            {
                query = query.Where(sp => sp.FolderName == folderName);
            }

            var savedPosts = await query
                .OrderByDescending(sp => sp.SavedAt)
                .ToListAsync();

            var result = savedPosts.Select(sp => new SavedPostDto
            {
                IdPost = sp.IdPost,
                IdUser = sp.IdUser,
                SavedAt = sp.SavedAt,
                FolderName = sp.FolderName,
                Note = sp.Note,
                Post = sp.Post != null ? new SocialPostDto
                {
                    IdPost = sp.Post.IdPost,
                    IdUser = sp.Post.IdUser,
                    UserName = sp.Post.User?.UserName,
                    AvatarUrl = sp.Post.User?.AvatarUrl,
                    Content = sp.Post.Content,
                    ImageUrl = sp.Post.ImageUrl,
                    VideoUrl = sp.Post.VideoUrl,
                    Visibility = sp.Post.Visibility,
                    CreatedAt = sp.Post.CreatedAt,
                    UpdatedAt = sp.Post.UpdatedAt,
                    LikesCount = _context.SocialReactions.Count(r => r.IdPost == sp.Post.IdPost),
                    CommentsCount = _context.SocialComments.Count(c => c.IdPost == sp.Post.IdPost),
                    SharesCount = _context.SocialShares.Count(s => s.IdPost == sp.Post.IdPost)
                } : null
            }).ToList();

            return Ok(result);
        }

        // GET: api/SavedPosts/folders/{idUser}
        [HttpGet("folders/{idUser}")]
        public async Task<ActionResult<List<string>>> GetFolders(string idUser)
        {
            var folders = await _context.SavedPosts
                .Where(sp => sp.IdUser == idUser)
                .Select(sp => sp.FolderName)
                .Distinct()
                .ToListAsync();

            return Ok(folders);
        }

        // POST: api/SavedPosts
        [HttpPost]
        public async Task<ActionResult<SavedPostDto>> SavePost([FromBody] CreateSavedPostDto input)
        {
            var existing = await _context.SavedPosts
                .FirstOrDefaultAsync(sp => sp.IdPost == input.IdPost && sp.IdUser == input.IdUser);

            if (existing != null)
            {
                return Conflict("Bài viết đã được lưu.");
            }

            var savedPost = new SavedPost
            {
                IdPost = input.IdPost,
                IdUser = input.IdUser,
                FolderName = input.FolderName ?? "All Posts",
                Note = input.Note,
                SavedAt = DateTime.UtcNow
            };

            _context.SavedPosts.Add(savedPost);
            await _context.SaveChangesAsync();

            var post = await _context.SocialPosts
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.IdPost == input.IdPost);

            return CreatedAtAction(nameof(GetSavedPosts), new { idUser = savedPost.IdUser }, new SavedPostDto
            {
                IdPost = savedPost.IdPost,
                IdUser = savedPost.IdUser,
                SavedAt = savedPost.SavedAt,
                FolderName = savedPost.FolderName,
                Note = savedPost.Note,
                Post = post != null ? new SocialPostDto
                {
                    IdPost = post.IdPost,
                    IdUser = post.IdUser,
                    UserName = post.User?.UserName,
                    AvatarUrl = post.User?.AvatarUrl,
                    Content = post.Content,
                    ImageUrl = post.ImageUrl,
                    VideoUrl = post.VideoUrl,
                    Visibility = post.Visibility,
                    CreatedAt = post.CreatedAt,
                    UpdatedAt = post.UpdatedAt,
                    LikesCount = 0,
                    CommentsCount = 0,
                    SharesCount = 0
                } : null
            });
        }

        // PUT: api/SavedPosts
        [HttpPut]
        public async Task<IActionResult> UpdateSavedPost([FromBody] UpdateSavedPostDto input, [FromQuery] string idPost, [FromQuery] string idUser)
        {
            var savedPost = await _context.SavedPosts
                .FirstOrDefaultAsync(sp => sp.IdPost == idPost && sp.IdUser == idUser);

            if (savedPost == null) return NotFound();

            if (!string.IsNullOrEmpty(input.FolderName))
                savedPost.FolderName = input.FolderName;
            
            if (input.Note != null)
                savedPost.Note = input.Note;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/SavedPosts
        [HttpDelete]
        public async Task<IActionResult> DeleteSavedPost([FromQuery] string idPost, [FromQuery] string idUser)
        {
            var savedPost = await _context.SavedPosts
                .FirstOrDefaultAsync(sp => sp.IdPost == idPost && sp.IdUser == idUser);

            if (savedPost == null) return NotFound();

            _context.SavedPosts.Remove(savedPost);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

