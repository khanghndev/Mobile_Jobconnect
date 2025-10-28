using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using HuitWorks.WebAPI.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JobTransactionDetailsController : ControllerBase
    {
        private readonly JobConnectDbContext _context;

        public JobTransactionDetailsController(JobConnectDbContext context) => _context = context;

        // GET all
        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobTransactionDetailDto>>> GetAll()
        {
            var list = await _context.JobTransactionDetails
                .Select(d => new JobTransactionDetailDto
                {
                    IdTransaction = d.IdTransaction,
                    AmountFormatted = d.AmountFormatted,
                    AmountInWords = d.AmountInWords,
                    SenderName = d.SenderName,
                    SenderBank = d.SenderBank,
                    ReceiverName = d.ReceiverName,
                    ReceiverBank = d.ReceiverBank,
                    Content = d.Content,
                    Fee = d.Fee
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET by idTransaction
        [HttpGet("{idTransaction}")]
        public async Task<ActionResult<JobTransactionDetailDto>> GetById(string idTransaction)
        {
            var detail = await _context.JobTransactionDetails
                .Where(d => d.IdTransaction == idTransaction)
                .Select(d => new JobTransactionDetailDto
                {
                    IdTransaction = d.IdTransaction,
                    AmountFormatted = d.AmountFormatted,
                    AmountInWords = d.AmountInWords,
                    SenderName = d.SenderName,
                    SenderBank = d.SenderBank,
                    ReceiverName = d.ReceiverName,
                    ReceiverBank = d.ReceiverBank,
                    Content = d.Content,
                    Fee = d.Fee
                })
                .FirstOrDefaultAsync();

            if (detail == null)
                return NotFound();

            return Ok(detail);
        }

        // POST
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateJobTransactionDetailDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var entity = new JobTransactionDetail
            {
                IdTransaction = dto.IdTransaction,
                AmountFormatted = dto.AmountFormatted,
                AmountInWords = dto.AmountInWords,
                SenderName = dto.SenderName,
                SenderBank = dto.SenderBank,
                ReceiverName = dto.ReceiverName,
                ReceiverBank = dto.ReceiverBank,
                Content = dto.Content,
                Fee = dto.Fee
            };

            _context.JobTransactionDetails.Add(entity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { idTransaction = entity.IdTransaction }, dto);
        }

        // PUT
        [HttpPut("{idTransaction}")]
        public async Task<IActionResult> Update(string idTransaction, [FromBody] CreateJobTransactionDetailDto dto)
        {
            var entity = await _context.JobTransactionDetails.FindAsync(idTransaction);
            if (entity == null)
                return NotFound();

            entity.AmountFormatted = dto.AmountFormatted;
            entity.AmountInWords = dto.AmountInWords;
            entity.SenderName = dto.SenderName;
            entity.SenderBank = dto.SenderBank;
            entity.ReceiverName = dto.ReceiverName;
            entity.ReceiverBank = dto.ReceiverBank;
            entity.Content = dto.Content;
            entity.Fee = dto.Fee;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE
        [HttpDelete("{idTransaction}")]
        public async Task<IActionResult> Delete(string idTransaction)
        {
            var entity = await _context.JobTransactionDetails.FindAsync(idTransaction);
            if (entity == null)
                return NotFound();

            _context.JobTransactionDetails.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
