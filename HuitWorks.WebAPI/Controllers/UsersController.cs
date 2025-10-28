using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public UserController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/user
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            var users = await _context.Users
                .Include(u => u.Role)
                .Select(u => new UserDto
                {
                    IdUser = u.IdUser,
                    UserName = u.UserName,
                    Email = u.Email,
                    PhoneNumber = u.PhoneNumber,
                    IdRole = u.IdRole,
                    AccountStatus = u.AccountStatus,
                    AvatarUrl = u.AvatarUrl,
                    SocialLogin = u.SocialLogin,
                    CreatedAt = u.CreatedAt,
                    UpdatedAt = u.UpdatedAt,
                    Gender = u.Gender,
                    Address = u.Address,
                    Role = u.Role != null
                        ? new Role
                        {
                            IdRole = u.Role.IdRole,
                            RoleName = u.Role.RoleName,
                            Description = u.Role.Description
                        }
                        : new Role
                        {
                            IdRole = "",
                            RoleName = "",
                            Description = ""
                        }
                })
                .ToListAsync();

            return Ok(users);
        }

        // GET: api/user/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<UserDto>> GetUser(string id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.IdUser == id);

            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            var userDto = new UserDto
            {
                IdUser = user.IdUser,
                UserName = user.UserName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber ?? string.Empty,
                Password = user.Password,
                IdRole = user.IdRole,
                AccountStatus = user.AccountStatus,
                AvatarUrl = user.AvatarUrl,
                SocialLogin = user.SocialLogin,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt,
                Gender = user.Gender,
                Address = user.Address,
                DateOfBirth = user.DateOfBirth,
                Role = user.Role != null
                    ? new Role
                    {
                        IdRole = user.Role.IdRole,
                        RoleName = user.Role.RoleName,
                        Description = user.Role.Description
                    }
                    : new Role
                    {
                        IdRole = "",
                        RoleName = "",
                        Description = ""
                    }
            };

            return Ok(userDto);
        }

        // POST: api/user
        [HttpPost]
        public async Task<ActionResult<UserDto>> CreateUser(CreateUserDto dto)
        {
            var user = new User
            {
                IdUser = dto.IdUser,
                UserName = dto.UserName,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber ?? "",
                Password = dto.Password,
                IdRole = dto.IdRole,
                AccountStatus = "active",
                AvatarUrl = dto.AvatarUrl,
                SocialLogin = dto.SocialLogin,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Gender = "other",
                Address = null,
                DateOfBirth = null
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var role = await _context.Roles.FindAsync(user.IdRole);

            var createdUserDto = new UserDto
            {
                IdUser = user.IdUser,
                UserName = user.UserName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                IdRole = user.IdRole,
                AccountStatus = user.AccountStatus,
                AvatarUrl = user.AvatarUrl,
                SocialLogin = user.SocialLogin,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt,
                Role = role != null
                    ? new Role
                    {
                        IdRole = role.IdRole,
                        RoleName = role.RoleName,
                        Description = role.Description
                    }
                    : new Role
                    {
                        IdRole = "",
                        RoleName = "",
                        Description = ""
                    }
            };

            return CreatedAtAction(nameof(GetUser), new { id = user.IdUser }, createdUserDto);
        }

        // PUT: api/user/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, UpdateUserDto dto)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            user.UserName = dto.UserName ?? user.UserName;
            user.Email = dto.Email ?? user.Email;
            user.PhoneNumber = dto.PhoneNumber ?? user.PhoneNumber;
            user.Address = dto.Address ?? user.Address;
            user.DateOfBirth = dto.DateOfBirth;
            user.Gender = dto.Gender ?? user.Gender;
            user.AvatarUrl = dto.AvatarUrl ?? user.AvatarUrl;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/user/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // PATCH: api/user/{id}/status
        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] UpdateStatusDto dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Status))
                return BadRequest(new { message = "accountStatus is required." });

            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found." });

            user.AccountStatus = dto.Status;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Entry(user).Property(u => u.AccountStatus).IsModified = true;
            _context.Entry(user).Property(u => u.UpdatedAt).IsModified = true;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
