using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using System.Linq;
using System.Text.RegularExpressions;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public SearchController(JobConnectDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy gợi ý tìm kiếm
        /// </summary>
        [HttpGet("suggestions")]
        public async Task<IActionResult> GetSearchSuggestions([FromQuery] string q)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
            {
                return Ok(new List<object>());
            }

            try
            {
                var suggestions = new List<object>();
                var query = q.ToLower();

                // Tìm kiếm hashtags từ SocialPost
                var hashtags = await _context.SocialPosts
                    .Where(p => p.Content.Contains("#"))
                    .Select(p => p.Content)
                    .ToListAsync();

                var hashtagList = new List<string>();
                foreach (var content in hashtags)
                {
                    var matches = Regex.Matches(content, @"#\w+");
                    foreach (Match match in matches)
                    {
                        hashtagList.Add(match.Value);
                    }
                }

                var popularHashtags = hashtagList
                    .GroupBy(h => h)
                    .OrderByDescending(g => g.Count())
                    .Take(5)
                    .Where(g => g.Key.ToLower().Contains(query))
                    .Select(g => new
                    {
                        type = "hashtag",
                        value = g.Key,
                        title = g.Key,
                        subtitle = $"{g.Count()} bài viết"
                    });

                suggestions.AddRange(popularHashtags);

                // Tìm kiếm users
                var users = await _context.Users
                    .Where(u => (u.UserName != null && u.UserName.ToLower().Contains(query)) || 
                               (u.Email != null && u.Email.ToLower().Contains(query)))
                    .Take(3)
                    .Select(u => new
                    {
                        type = "user",
                        value = u.UserName ?? u.Email ?? "Người dùng",
                        title = u.UserName ?? u.Email ?? "Người dùng",
                        subtitle = $"{u.Email} • {u.Address ?? "Chưa cập nhật"}"
                    })
                    .ToListAsync();

                suggestions.AddRange(users);

                // Tìm kiếm skills
                var skills = await _context.CandidateSkills
                    .Where(s => s.SkillName.ToLower().Contains(query))
                    .GroupBy(s => s.SkillName)
                    .OrderByDescending(g => g.Count())
                    .Take(3)
                    .Select(g => new
                    {
                        type = "skill",
                        value = g.Key,
                        title = g.Key,
                        subtitle = $"{g.Count()} người dùng"
                    })
                    .ToListAsync();

                suggestions.AddRange(skills);

                // Tìm kiếm posts
                var posts = await _context.SocialPosts
                    .Where(p => p.Content.ToLower().Contains(query))
                    .OrderByDescending(p => p.CreatedAt)
                    .Take(2)
                    .Select(p => new
                    {
                        type = "post",
                        value = p.Content.Length > 50 ? p.Content.Substring(0, 50) + "..." : p.Content,
                        title = p.Content.Length > 50 ? p.Content.Substring(0, 50) + "..." : p.Content,
                        subtitle = $"Bài viết • {p.CreatedAt:dd/MM/yyyy}"
                    })
                    .ToListAsync();

                suggestions.AddRange(posts);

                return Ok(suggestions.Take(6));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm gợi ý", error = ex.Message });
            }
        }

        /// <summary>
        /// Tìm kiếm bài viết
        /// </summary>
        [HttpGet("posts")]
        public async Task<IActionResult> SearchPosts([FromQuery] string q)
        {
            if (string.IsNullOrWhiteSpace(q))
            {
                return Ok(new List<object>());
            }

            try
            {
                var query = q.ToLower();

                var posts = await _context.SocialPosts
                    .Include(p => p.User)
                    .Where(p => p.Content.ToLower().Contains(query))
                    .OrderByDescending(p => p.CreatedAt)
                    .Take(20)
                    .Select(p => new
                    {
                        id = p.IdPost,
                        type = p.PostType,
                        title = p.Content.Length > 100 ? p.Content.Substring(0, 100) + "..." : p.Content,
                        content = p.Content,
                        author = p.User.UserName ?? p.User.Email ?? "Người dùng",
                        avatar = p.User.AvatarUrl ?? $"https://ui-avatars.com/api/?name={Uri.EscapeDataString(p.User.UserName ?? p.User.Email ?? "User")}",
                        idUser = p.IdUser,
                        imageUrl = p.ImageUrl,
                        videoUrl = p.VideoUrl,
                        createdAt = p.CreatedAt,
                        likes = _context.SocialReactions.Count(l => l.IdPost == p.IdPost),
                        comments = _context.SocialComments.Count(c => c.IdPost == p.IdPost)
                    })
                    .ToListAsync();

                // Xử lý hashtags sau khi query để tránh lỗi Entity Framework
                var processedPosts = posts.Select(p => new
                {
                    p.id,
                    p.type,
                    p.title,
                    p.content,
                    p.author,
                    p.avatar,
                    p.idUser,
                    p.imageUrl,
                    p.videoUrl,
                    p.createdAt,
                    p.likes,
                    p.comments,
                    hashtags = ExtractHashtags(p.content)
                }).ToList();

                return Ok(processedPosts);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm bài viết", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy danh sách người dùng
        /// </summary>
        [HttpGet("users")]
        public async Task<IActionResult> GetUsers()
        {
            try
            {
                var users = await _context.Users
                    .Where(u => u.AccountStatus == "active")
                    .OrderByDescending(u => u.CreatedAt)
                    .Take(50)
                    .Select(u => new
                    {
                        id = u.IdUser,
                        name = u.UserName ?? u.Email ?? "Người dùng",
                        title = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.WorkPosition)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        location = u.Address ?? "Chưa cập nhật",
                        avatar = u.AvatarUrl ?? $"https://ui-avatars.com/api/?name={Uri.EscapeDataString(u.UserName ?? u.Email ?? "User")}",
                        skills = _context.CandidateSkills
                            .Where(cs => cs.IdUser == u.IdUser)
                            .Select(cs => cs.SkillName)
                            .Take(5)
                            .ToArray(),
                        education = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.EducationLevel)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        stats = new
                        {
                            posts = _context.SocialPosts.Count(p => p.IdUser == u.IdUser),
                            followers = _context.SocialFollows.Count(f => f.FollowingId == u.IdUser),
                            following = _context.SocialFollows.Count(f => f.FollowerId == u.IdUser)
                        },
                        bio = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.FreeTime)
                            .FirstOrDefault() ?? "Chưa cập nhật thông tin",
                        email = u.Email,
                        phone = u.PhoneNumber ?? "Chưa cập nhật",
                        // Store raw data for processing outside LINQ
                        accountStatus = u.AccountStatus,
                        createdAt = u.CreatedAt,
                        experienceYears = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.ExperienceYears)
                            .FirstOrDefault()
                    })
                    .ToListAsync();

                // Process status and experience after query
                var processedUsers = users.Select(u => new
                {
                    u.id,
                    u.name,
                    u.title,
                    u.location,
                    u.avatar,
                    status = GetUserStatus(u.accountStatus),
                    u.skills,
                    experience = GetExperienceLevel(u.experienceYears, u.createdAt),
                    u.education,
                    u.stats,
                    u.bio,
                    u.email,
                    u.phone
                }).ToList();

                return Ok(processedUsers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy danh sách người dùng", error = ex.Message });
            }
        }

        /// <summary>
        /// Tìm kiếm người dùng
        /// </summary>
        [HttpGet("users/search")]
        public async Task<IActionResult> SearchUsers(
            [FromQuery] string q = "",
            [FromQuery] string location = "",
            [FromQuery] string jobTitle = "",
            [FromQuery] string skills = "",
            [FromQuery] string experience = "",
            [FromQuery] string education = "",
            [FromQuery] string status = "",
            [FromQuery] string sort = "relevance")
        {
            try
            {
                var query = _context.Users
                    .Where(u => u.AccountStatus == "active");

                // Text search
                if (!string.IsNullOrWhiteSpace(q))
                {
                    var searchQuery = q.ToLower();
                    query = query.Where(u => 
                        (u.UserName != null && u.UserName.ToLower().Contains(searchQuery)) ||
                        (u.Email != null && u.Email.ToLower().Contains(searchQuery)) ||
                        _context.CandidateInfo.Any(ci => ci.IdUser == u.IdUser && ci.WorkPosition != null && ci.WorkPosition.ToLower().Contains(searchQuery)) ||
                        _context.CandidateSkills.Any(cs => cs.IdUser == u.IdUser && cs.SkillName.ToLower().Contains(searchQuery))
                    );
                }

                // Location filter
                if (!string.IsNullOrWhiteSpace(location))
                {
                    query = query.Where(u => u.Address != null && u.Address.ToLower().Contains(location.ToLower()));
                }

                // Job title filter
                if (!string.IsNullOrWhiteSpace(jobTitle))
                {
                    query = query.Where(u => _context.CandidateInfo.Any(ci => ci.IdUser == u.IdUser && ci.WorkPosition != null && ci.WorkPosition.ToLower().Contains(jobTitle.ToLower())));
                }

                // Skills filter
                if (!string.IsNullOrWhiteSpace(skills))
                {
                    var skillList = skills.Split(',', StringSplitOptions.RemoveEmptyEntries)
                        .Select(s => s.Trim().ToLower())
                        .ToArray();
                    
                    query = query.Where(u => _context.CandidateSkills.Any(cs => cs.IdUser == u.IdUser && 
                        skillList.Any(skill => cs.SkillName.ToLower().Contains(skill))
                    ));
                }

                // Education filter
                if (!string.IsNullOrWhiteSpace(education))
                {
                    query = query.Where(u => _context.CandidateInfo.Any(ci => ci.IdUser == u.IdUser && ci.EducationLevel != null && ci.EducationLevel.ToLower().Contains(education.ToLower())));
                }

                // Apply sorting
                switch (sort.ToLower())
                {
                    case "name":
                        query = query.OrderBy(u => u.UserName ?? u.Email);
                        break;
                    case "popular":
                        query = query.OrderByDescending(u => _context.SocialFollows.Count(f => f.FollowingId == u.IdUser));
                        break;
                    case "newest":
                        query = query.OrderByDescending(u => u.CreatedAt);
                        break;
                    default: // relevance
                        query = query.OrderByDescending(u => u.CreatedAt);
                        break;
                }

                var users = await query
                    .Take(50)
                    .Select(u => new
                    {
                        id = u.IdUser,
                        name = u.UserName ?? u.Email ?? "Người dùng",
                        title = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.WorkPosition)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        location = u.Address ?? "Chưa cập nhật",
                        avatar = u.AvatarUrl ?? $"https://ui-avatars.com/api/?name={Uri.EscapeDataString(u.UserName ?? u.Email ?? "User")}",
                        skills = _context.CandidateSkills
                            .Where(cs => cs.IdUser == u.IdUser)
                            .Select(cs => cs.SkillName)
                            .Take(5)
                            .ToArray(),
                        education = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.EducationLevel)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        stats = new
                        {
                            posts = _context.SocialPosts.Count(p => p.IdUser == u.IdUser),
                            followers = _context.SocialFollows.Count(f => f.FollowingId == u.IdUser),
                            following = _context.SocialFollows.Count(f => f.FollowerId == u.IdUser)
                        },
                        bio = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.FreeTime)
                            .FirstOrDefault() ?? "Chưa cập nhật thông tin",
                        email = u.Email,
                        phone = u.PhoneNumber ?? "Chưa cập nhật",
                        // Store raw data for processing outside LINQ
                        accountStatus = u.AccountStatus,
                        createdAt = u.CreatedAt,
                        experienceYears = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.ExperienceYears)
                            .FirstOrDefault()
                    })
                    .ToListAsync();

                // Process status and experience after query
                var processedUsers = users.Select(u => new
                {
                    u.id,
                    u.name,
                    u.title,
                    u.location,
                    u.avatar,
                    status = GetUserStatus(u.accountStatus),
                    u.skills,
                    experience = GetExperienceLevel(u.experienceYears, u.createdAt),
                    u.education,
                    u.stats,
                    u.bio,
                    u.email,
                    u.phone
                }).ToList();

                // Apply status and experience filters after processing
                if (!string.IsNullOrWhiteSpace(status))
                {
                    processedUsers = processedUsers.Where(u => u.status == status).ToList();
                }

                if (!string.IsNullOrWhiteSpace(experience))
                {
                    processedUsers = processedUsers.Where(u => u.experience == experience).ToList();
                }

                return Ok(processedUsers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi tìm kiếm người dùng", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy gợi ý người dùng
        /// </summary>
        [HttpGet("users/suggestions")]
        public async Task<IActionResult> GetUserSuggestions([FromQuery] string q)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
            {
                return Ok(new List<object>());
            }

            try
            {
                var query = q.ToLower();
                var suggestions = new List<object>();

                // User suggestions
                var users = await _context.Users
                    .Where(u => u.AccountStatus == "active" && 
                               ((u.UserName != null && u.UserName.ToLower().Contains(query)) || 
                                (u.Email != null && u.Email.ToLower().Contains(query))))
                    .Take(3)
                    .Select(u => new
                    {
                        type = "user",
                        value = u.IdUser, // Use user ID instead of name
                        title = u.UserName ?? u.Email ?? "Người dùng",
                        subtitle = $"{_context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.WorkPosition)
                            .FirstOrDefault() ?? "Chưa cập nhật"} • {u.Address ?? "Chưa cập nhật"}"
                    })
                    .ToListAsync();

                suggestions.AddRange(users);

                // Skill suggestions
                var skills = await _context.CandidateSkills
                    .Where(s => s.SkillName.ToLower().Contains(query))
                    .GroupBy(s => s.SkillName)
                    .OrderByDescending(g => g.Count())
                    .Take(2)
                    .Select(g => new
                    {
                        type = "skill",
                        value = g.Key,
                        title = g.Key,
                        subtitle = $"{g.Count()} người dùng"
                    })
                    .ToListAsync();

                suggestions.AddRange(skills);

                // Location suggestions
                var locations = await _context.Users
                    .Where(u => u.AccountStatus == "active" && 
                               u.Address != null && 
                               u.Address.ToLower().Contains(query))
                    .GroupBy(u => u.Address)
                    .OrderByDescending(g => g.Count())
                    .Take(2)
                    .Select(g => new
                    {
                        type = "location",
                        value = g.Key,
                        title = g.Key,
                        subtitle = $"{g.Count()} người dùng"
                    })
                    .ToListAsync();

                suggestions.AddRange(locations);

                return Ok(suggestions.Take(5));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy gợi ý người dùng", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy thông tin profile của user theo ID
        /// </summary>
        [HttpGet("users/{userId}")]
        public async Task<IActionResult> GetUserProfile(string userId)
        {
            try
            {
                var user = await _context.Users
                    .Where(u => u.IdUser == userId && u.AccountStatus == "active")
                    .Select(u => new
                    {
                        id = u.IdUser,
                        name = u.UserName ?? u.Email ?? "Người dùng",
                        title = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.WorkPosition)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        location = u.Address ?? "Chưa cập nhật",
                        avatar = u.AvatarUrl ?? $"https://ui-avatars.com/api/?name={Uri.EscapeDataString(u.UserName ?? u.Email ?? "User")}",
                        // status = GetUserStatus(u), // Will process after query
                        skills = _context.CandidateSkills
                            .Where(cs => cs.IdUser == u.IdUser)
                            .Select(cs => cs.SkillName)
                            .Take(10)
                            .ToArray(),
                        // experience = GetExperienceLevel(u), // Will process after query
                        education = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.EducationLevel)
                            .FirstOrDefault() ?? "Chưa cập nhật",
                        stats = new
                        {
                            posts = _context.SocialPosts.Count(p => p.IdUser == u.IdUser),
                            followers = _context.SocialFollows.Count(f => f.FollowingId == u.IdUser),
                            following = _context.SocialFollows.Count(f => f.FollowerId == u.IdUser)
                        },
                        bio = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.FreeTime)
                            .FirstOrDefault() ?? "Chưa cập nhật thông tin",
                        email = u.Email,
                        phone = u.PhoneNumber ?? "Chưa cập nhật",
                        gender = u.Gender ?? "Chưa cập nhật",
                        dateOfBirth = u.DateOfBirth,
                        createdAt = u.CreatedAt,
                        // Store raw data for processing outside LINQ
                        accountStatus = u.AccountStatus,
                        experienceYears = _context.CandidateInfo
                            .Where(ci => ci.IdUser == u.IdUser)
                            .Select(ci => ci.ExperienceYears)
                            .FirstOrDefault()
                    })
                    .FirstOrDefaultAsync();

                if (user == null)
                {
                    return NotFound(new { message = "Không tìm thấy người dùng" });
                }

                // Process status and experience after query
                var processedUser = new
                {
                    user.id,
                    user.name,
                    user.title,
                    user.location,
                    user.avatar,
                    status = GetUserStatus(user.accountStatus),
                    user.skills,
                    experience = GetExperienceLevel(user.experienceYears, user.createdAt),
                    user.education,
                    user.stats,
                    user.bio,
                    user.email,
                    user.phone,
                    user.gender,
                    user.dateOfBirth,
                    user.createdAt
                };

                return Ok(processedUser);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy thông tin người dùng", error = ex.Message });
            }
        }

        #region Helper Methods

        private string GetUserStatus(string accountStatus)
        {
            // Logic để xác định trạng thái user
            if (accountStatus != "active")
                return "inactive";
            
            // Có thể thêm logic phức tạp hơn dựa vào dữ liệu khác
            return "available";
        }

        private string GetExperienceLevel(int? experienceYears, DateTime? createdAt)
        {
            // Logic để xác định mức độ kinh nghiệm dựa vào CandidateInfo
            if (experienceYears == null)
            {
                if (createdAt == null)
                    return "0-1";
                
                var years = DateTime.Now.Year - createdAt.Value.Year;
                if (years < 1) return "0-1";
                if (years < 3) return "1-3";
                if (years < 5) return "3-5";
                return "5+";
            }
            
            if (experienceYears < 1) return "0-1";
            if (experienceYears < 3) return "1-3";
            if (experienceYears < 5) return "3-5";
            return "5+";
        }

        private string[] ExtractHashtags(string content)
        {
            if (string.IsNullOrEmpty(content))
                return new string[0];
            
            var matches = Regex.Matches(content, @"#\w+");
            return matches.Cast<Match>()
                .Select(m => m.Value)
                .Where(h => !string.IsNullOrEmpty(h))
                .ToArray();
        }

        #endregion
    }
}
