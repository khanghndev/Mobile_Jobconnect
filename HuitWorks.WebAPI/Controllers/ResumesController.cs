using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using System.Transactions;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResumeController : ControllerBase
    {
        private readonly JobConnectDbContext _context;
        public ResumeController(JobConnectDbContext context)
        {
            _context = context;
        }

        private string GetCurrentUserId()
        {
            return User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                   ?? User.FindFirst("sub")?.Value
                   ?? "";
        }

        // ===============================
        // 1) GET: api/resume
        // ===============================
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ResumeDto>>> GetAll()
        {
            var list = await _context.Resumes
                .Select(r => new ResumeDto
                {
                    IdResume = r.IdResume,
                    IdUser = r.IdUser,
                    FileUrl = r.FileUrl,
                    FileName = r.FileName,
                    FileId = r.FileId,
                    FileSizeKB = r.FileSizeKB,
                    IsDefault = r.IsDefault,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // =======================================================
        // 2) GET: api/resume/{idUser}
        // =======================================================
        [HttpGet("{idUser}")]
        public async Task<ActionResult<IEnumerable<ResumeDto>>> GetByIdUser(string idUser)
        {
            var list = await _context.Resumes
                .Where(r => r.IdUser == idUser)
                .Select(r => new ResumeDto
                {
                    IdResume = r.IdResume,
                    IdUser = r.IdUser,
                    FileUrl = r.FileUrl,
                    FileName = r.FileName,
                    FileId = r.FileId,
                    FileSizeKB = r.FileSizeKB,
                    IsDefault = r.IsDefault,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt
                })
                .ToListAsync();

            if (list == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ." });

            return Ok(list);
        }

        // ================================================================
        // 3) GET: api/resume/by-user/{userId} - Get single resume for viewing (with transaction check)
        // ================================================================
        [HttpGet("by-user/{candidateId}")]
        public async Task<IActionResult> GetByUser(string candidateId)
        {
            var resume = await _context.Resumes
                .Where(r => r.IdUser == candidateId)
                .OrderByDescending(r => r.IsDefault)
                .FirstOrDefaultAsync();

            if (resume == null)
                return NotFound(new { message = "Ứng viên chưa có hồ sơ." });

            var idViewer = GetCurrentUserId();
            if (string.IsNullOrEmpty(idViewer))
                return Unauthorized(new { message = "Không tìm thấy thông tin user." });

            var nowUtc = DateTime.UtcNow;
            var activeTx = await _context.JobTransactions
                .Where(t =>
                    t.IdUser == idViewer &&
                    t.Status == "Completed" &&
                    t.ExpiryDate >= nowUtc &&
                    t.RemainingCvViews > 0)
                .OrderByDescending(t => t.ExpiryDate)
                .FirstOrDefaultAsync();

            if (activeTx == null)
                return BadRequest(new { message = "Bạn đã hết lượt xem hồ sơ hoặc không có gói xem hồ sơ hợp lệ." });

            activeTx.RemainingCvViews -= 1;
            _context.JobTransactions.Update(activeTx);

            var log = new CvViewUsageLog
            {
                IdLog = Guid.NewGuid().ToString(),
                IdTransaction = activeTx.IdTransaction,
                IdResume = resume.IdResume,
                UsedAt = nowUtc
            };
            _context.CvViewUsageLogs.Add(log);

            await _context.SaveChangesAsync();

            var result = new ResumeDto
            {
                IdResume = resume.IdResume,
                IdUser = resume.IdUser,
                FileUrl = resume.FileUrl,
                FileName = resume.FileName,
                FileSizeKB = resume.FileSizeKB,
                IsDefault = resume.IsDefault,
                CreatedAt = resume.CreatedAt,
                UpdatedAt = resume.UpdatedAt
            };
            return Ok(result);
        }

        // ================================================================
        // 4) GET: api/resume/user/{userId} - Get all resumes for a user (for profile management)
        // ================================================================
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<ResumeDto>>> GetByUserId(string userId)
        {
            var list = await _context.Resumes
                .Where(r => r.IdUser == userId)
                .OrderByDescending(r => r.IsDefault)
                .ThenByDescending(r => r.CreatedAt)
                .Select(r => new ResumeDto
                {
                    IdResume = r.IdResume,
                    IdUser = r.IdUser,
                    FileUrl = r.FileUrl,
                    FileName = r.FileName,
                    FileId = r.FileId,
                    FileSizeKB = r.FileSizeKB,
                    IsDefault = r.IsDefault,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // ===============================
        // 4) POST: api/resume
        // ===============================
        [HttpPost]
        public async Task<ActionResult<ResumeDto>> Create([FromBody] CreateResumeDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (!await _context.Users.AnyAsync(u => u.IdUser == dto.IdUser))
                return BadRequest(new { message = "Người dùng không tồn tại." });

            var entity = new Resume
            {
                IdResume = Guid.NewGuid().ToString(),
                IdUser = dto.IdUser,
                FileUrl = dto.FileUrl,
                FileName = dto.FileName,
                FileId = dto.FileId,
                FileSizeKB = dto.FileSizeKB,
                IsDefault = dto.IsDefault,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Resumes.Add(entity);
            await _context.SaveChangesAsync();

            var result = new ResumeDto
            {
                IdResume = entity.IdResume,
                IdUser = entity.IdUser,
                FileUrl = entity.FileUrl,
                FileName = entity.FileName,
                FileId = entity.FileId,
                FileSizeKB = entity.FileSizeKB,
                IsDefault = entity.IsDefault,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
            return CreatedAtAction(nameof(GetByIdUser), new { idUser = result.IdUser }, result);
        }

        // ===============================
        // 5) PUT: api/resume/{id}
        // ===============================
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateResumeDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = await _context.Resumes.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ." });

            entity.FileUrl = dto.FileUrl ?? entity.FileUrl;
            entity.FileName = dto.FileName ?? entity.FileName;
            entity.FileSizeKB = dto.FileSizeKB ?? entity.FileSizeKB;
            entity.IsDefault = dto.IsDefault ?? entity.IsDefault;
            entity.UpdatedAt = DateTime.UtcNow;

            _context.Resumes.Update(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // ===============================
        // 6) DELETE: api/resume/{id}
        // ===============================
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var entity = await _context.Resumes.FindAsync(id);
            if (entity == null)
                return NotFound(new { message = "Không tìm thấy hồ sơ." });

            _context.Resumes.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // ===============================
        // 7) POST: api/resume/set-default
        // ===============================
        [HttpPost("set-default")]
        public async Task<IActionResult> SetDefault([FromBody] SetDefaultResumeDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.UserId) || (string.IsNullOrWhiteSpace(dto.FileId) && string.IsNullOrWhiteSpace(dto.ResumeId)))
                return BadRequest(new { message = "Thiếu UserId và (ResumeId hoặc FileId)." });

            var q = _context.Resumes.AsQueryable().Where(r => r.IdUser == dto.UserId);
            if (!string.IsNullOrEmpty(dto.ResumeId)) q = q.Where(r => r.IdResume == dto.ResumeId);
            else q = q.Where(r => r.FileId == dto.FileId);

            var target = await q.FirstOrDefaultAsync();
            if (target == null) return NotFound(new { message = "Không tìm thấy CV cần đặt mặc định." });

            using var scope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled);

            await _context.Resumes
                .Where(r => r.IdUser == dto.UserId && r.IsDefault == 1)
                .ExecuteUpdateAsync(s => s.SetProperty(r => r.IsDefault, 0));

            target.IsDefault = 1;
            target.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            scope.Complete();
            return Ok(new { message = "Đã đặt CV làm mặc định." });
        }

        // ===============================
        // 8) GET: api/resume/download/{userId}/{fileId}
        // ===============================
        [HttpGet("download/{userId}/{fileId}")]
        public async Task<IActionResult> DownloadResume(string userId, string fileId)
        {
            var resume = await _context.Resumes
                .FirstOrDefaultAsync(r => r.IdUser == userId && r.FileId == fileId);

            if (resume == null)
                return NotFound(new { message = "Không tìm thấy CV." });

            // Trả về thông tin file để frontend có thể download
            return Ok(new
            {
                fileUrl = resume.FileUrl,
                fileName = resume.FileName,
                fileSize = resume.FileSizeKB
            });
        }
        // DTO thêm tùy chọn truyền theo IdResume hoặc FileId
        public class SetDefaultResumeDto
        {
            public string UserId { get; set; } = default!;
            public string? FileId { get; set; }
            public string? ResumeId { get; set; }
        }

    }
}
