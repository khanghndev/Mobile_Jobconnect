// File: Controllers/JobTransactionController.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JobTransactionController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public JobTransactionController(JobConnectDbContext context)
        {
            _context = context;
        }

        // =========================================================================
        // 1) GET: api/JobTransaction
        // =========================================================================
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobTransactionDto>>> GetAll()
        {
            var list = await _context.JobTransactions
                .Select(t => new JobTransactionDto
                {
                    IdTransaction = t.IdTransaction,
                    IdUser = t.IdUser,
                    IdPackage = t.IdPackage,
                    Amount = t.Amount,
                    PaymentMethod = t.PaymentMethod,
                    TransactionDate = t.TransactionDate,
                    Status = t.Status,
                    StartDate = t.StartDate,
                    ExpiryDate = t.ExpiryDate,
                    RemainingJobPosts = t.RemainingJobPosts,
                    RemainingCvViews = t.RemainingCvViews
                })
                .ToListAsync();

            return Ok(list);
        }

        // =========================================================================
        // 2) GET: api/JobTransaction/{id}
        // =========================================================================
        [HttpGet("{id}")]
        public async Task<ActionResult<JobTransactionDto>> GetById(string id)
        {
            var t = await _context.JobTransactions.FindAsync(id);
            if (t == null)
                return NotFound(new { message = "JobTransaction not found." });

            var dto = new JobTransactionDto
            {
                IdTransaction = t.IdTransaction,
                IdUser = t.IdUser,
                IdPackage = t.IdPackage,
                Amount = t.Amount,
                PaymentMethod = t.PaymentMethod,
                TransactionDate = t.TransactionDate,
                Status = t.Status,
                StartDate = t.StartDate,
                ExpiryDate = t.ExpiryDate,
                RemainingJobPosts = t.RemainingJobPosts,
                RemainingCvViews = t.RemainingCvViews
            };

            return Ok(dto);
        }

        // =========================================================================
        // 3) GET: api/JobTransaction/user/{userId}
        // =========================================================================
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<JobTransactionDto>>> GetByUser(string userId)
        {
            var userExists = await _context.Users.AnyAsync(u => u.IdUser == userId);
            if (!userExists)
                return NotFound(new { message = "User not found." });

            var now = DateTime.UtcNow;
            var transactions = await _context.JobTransactions
                .Where(t =>
                    t.IdUser == userId &&
                    t.Status == "Completed" &&
                    t.ExpiryDate >= now &&
                    t.RemainingJobPosts > 0
                )
                .OrderByDescending(t => t.ExpiryDate)
                .Select(t => new JobTransactionDto
                {
                    IdTransaction = t.IdTransaction,
                    IdUser = t.IdUser,
                    IdPackage = t.IdPackage,
                    Amount = t.Amount,
                    PaymentMethod = t.PaymentMethod,
                    TransactionDate = t.TransactionDate,
                    Status = t.Status,
                    StartDate = t.StartDate,
                    ExpiryDate = t.ExpiryDate,
                    RemainingJobPosts = t.RemainingJobPosts,
                    RemainingCvViews = t.RemainingCvViews
                })
                .ToListAsync();

            return Ok(transactions);
        }

        // =========================================================================
        // 4) POST: api/JobTransaction
        // =========================================================================
        [HttpPost]
        public async Task<ActionResult<JobTransactionDto>> Create([FromBody] CreateJobTransactionDto dto)
        {
            var newId = Guid.NewGuid().ToString();
            if (await _context.JobTransactions.AnyAsync(x => x.IdTransaction == newId))
                return Conflict(new { message = "GUID collision, please try again." });

            var userExists = await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser);
            if (!userExists)
                return BadRequest(new { message = "Referenced user does not exist." });

            var package = await _context.SubscriptionPackages.FindAsync(dto.IdPackage);
            if (package == null)
                return BadRequest(new { message = "Referenced subscription package does not exist." });

            var transactionDate = dto.TransactionDate;
            var startDate = transactionDate;
            var expiryDate = transactionDate.AddDays(package.DurationDays);

            var entity = new JobTransaction
            {
                IdTransaction = newId,
                IdUser = dto.IdUser,
                IdPackage = dto.IdPackage,
                Amount = dto.Amount,
                PaymentMethod = dto.PaymentMethod,
                TransactionDate = transactionDate,
                Status = dto.Status,
                StartDate = startDate,
                ExpiryDate = expiryDate,

                RemainingJobPosts = package.JobPostLimit,
                RemainingCvViews = package.CvViewLimit
            };

            _context.JobTransactions.Add(entity);
            await _context.SaveChangesAsync();

            var createdDto = new JobTransactionDto
            {
                IdTransaction = entity.IdTransaction,
                IdUser = entity.IdUser,
                IdPackage = entity.IdPackage,
                Amount = entity.Amount,
                PaymentMethod = entity.PaymentMethod,
                TransactionDate = entity.TransactionDate,
                Status = entity.Status,
                StartDate = entity.StartDate,
                ExpiryDate = entity.ExpiryDate,
                RemainingJobPosts = entity.RemainingJobPosts,
                RemainingCvViews = entity.RemainingCvViews
            };

            return CreatedAtAction(nameof(GetById), new { id = createdDto.IdTransaction }, createdDto);
        }

        // =========================================================================
        // 5) PUT: api/JobTransaction/{id}/use-jobpost
        // =========================================================================
        [HttpPut("{id}/use-jobpost")]
        public async Task<IActionResult> UseJobPost(string id)
        {
            var tx = await _context.JobTransactions.FindAsync(id);
            if (tx == null)
                return NotFound(new { message = "JobTransaction not found." });

            if (!string.Equals(tx.Status, "Completed", StringComparison.OrdinalIgnoreCase))
                return BadRequest(new { message = "Transaction chưa hoàn tất hoặc chưa được kích hoạt." });

            if (tx.ExpiryDate < DateTime.UtcNow)
                return BadRequest(new { message = "Gói của bạn đã hết hạn." });

            if (tx.RemainingJobPosts <= 0)
                return BadRequest(new { message = "Bạn đã sử dụng hết lượt đăng tin trong gói này." });

            tx.RemainingJobPosts -= 1;
            _context.JobTransactions.Update(tx);
            await _context.SaveChangesAsync();

            return NoContent();  // 204
        }

        // =========================================================================
        // 6) PUT: api/JobTransaction/{id}/use-cvview
        // =========================================================================
        [HttpPut("{id}/use-cvview")]
        public async Task<IActionResult> UseCvView(string id)
        {
            var tx = await _context.JobTransactions.FindAsync(id);
            if (tx == null)
                return NotFound(new { message = "JobTransaction not found." });

            if (!string.Equals(tx.Status, "Completed", StringComparison.OrdinalIgnoreCase) ||
                tx.ExpiryDate < DateTime.UtcNow)
            {
                return BadRequest(new { message = "Giao dịch chưa hoàn tất hoặc đã hết hạn." });
            }

            if (tx.RemainingCvViews <= 0)
                return BadRequest(new { message = "Bạn đã hết lượt xem hồ sơ trong gói này." });

            tx.RemainingCvViews -= 1;
            _context.JobTransactions.Update(tx);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // =========================================================================
        // 7) PUT: api/JobTransaction/{id}
        // =========================================================================
        public class UpdateJobTransactionDto
        {
            public string? PaymentMethod { get; set; }
            public string? Status { get; set; }
            public int? RemainingJobPosts { get; set; }
            public int? RemainingCvViews { get; set; }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateJobTransactionDto dto)
        {
            var entity = await _context.JobTransactions.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "JobTransaction not found." });

            if (dto.PaymentMethod != null)
                entity.PaymentMethod = dto.PaymentMethod;
            if (dto.Status != null)
                entity.Status = dto.Status;
            if (dto.RemainingJobPosts.HasValue)
                entity.RemainingJobPosts = dto.RemainingJobPosts.Value;
            if (dto.RemainingCvViews.HasValue)
                entity.RemainingCvViews = dto.RemainingCvViews.Value;

            _context.JobTransactions.Update(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // =========================================================================
        // 8) DELETE: api/JobTransaction/{id}
        // =========================================================================
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.JobTransactions.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "JobTransaction not found." });

            _context.JobTransactions.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
