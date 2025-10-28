using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;
using System;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SupportTicketsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public SupportTicketsController(JobConnectDbContext context)
        {
            _context = context;
        }

        [HttpGet("by-user/{userId}")]
        public async Task<ActionResult<IEnumerable<SupportTicketDto>>> ByUser(string userId)
        {
            var list = await _context.SupportTickets
                .Where(t => t.IdUser == userId)
                .OrderByDescending(t => t.UpdatedAt)
                .Select(t => new SupportTicketDto
                {
                    IdTicket = t.IdTicket,
                    IdUser = t.IdUser,
                    Subject = t.Subject,
                    Message = t.Message,
                    Status = t.Status,
                    CreatedAt = t.CreatedAt,
                    UpdatedAt = t.UpdatedAt
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<ActionResult<SupportTicketDto>> Create([FromBody] CreateSupportTicketDto input)
        {
            var entity = new SupportTicket
            {
                IdTicket = Guid.NewGuid().ToString("N"),
                IdUser = input.IdUser,
                Subject = input.Subject,
                Message = input.Message,
                Status = "open",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.SupportTickets.Add(entity);
            await _context.SaveChangesAsync();
            return Ok(new SupportTicketDto
            {
                IdTicket = entity.IdTicket,
                IdUser = entity.IdUser,
                Subject = entity.Subject,
                Message = entity.Message,
                Status = entity.Status,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            });
        }

        [HttpPatch("{ticketId}/status")]
        public async Task<IActionResult> UpdateStatus(string ticketId, [FromBody] UpdateSupportTicketStatusDto input)
        {
            var entity = await _context.SupportTickets.FindAsync(ticketId);
            if (entity == null) return NotFound();
            entity.Status = input.Status;
            entity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{ticketId}")]
        public async Task<IActionResult> Delete(string ticketId)
        {
            var entity = await _context.SupportTickets.FindAsync(ticketId);
            if (entity == null) return NotFound();
            _context.SupportTickets.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}


