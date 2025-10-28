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
    public class RolesController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public RolesController(JobConnectDbContext context)
        {
            _context = context;
        }

        // GET: api/role
        [HttpGet]
        public async Task<ActionResult<IEnumerable<RoleDto>>> GetRoles()
        {
            var roles = await _context.Roles
                .Select(r => new RoleDto
                {
                    IdRole = r.IdRole,
                    RoleName = r.RoleName,
                    Description = r.Description
                })
                .ToListAsync();

            return Ok(roles);
        }

        // GET: api/role/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<RoleDto>> GetRole(string id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò." });

            return Ok(new RoleDto
            {
                IdRole = role.IdRole,
                RoleName = role.RoleName,
                Description = role.Description
            });
        }

        // POST: api/role
        [HttpPost]
        public async Task<ActionResult<RoleDto>> CreateRole([FromBody] CreateRoleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var role = new Role
            {
                IdRole = Guid.NewGuid().ToString(),
                RoleName = dto.RoleName,
                Description = dto.Description
            };

            _context.Roles.Add(role);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetRole), new { id = role.IdRole }, new RoleDto
            {
                IdRole = role.IdRole,
                RoleName = role.RoleName,
                Description = role.Description
            });
        }

        // PUT: api/role/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRole(string id, [FromBody] UpdateRoleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.Roles.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy vai trò." });

            entity.RoleName = dto.RoleName ?? entity.RoleName;
            entity.Description = dto.Description ?? entity.Description;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/role/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRole(string id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò." });

            _context.Roles.Remove(role);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
