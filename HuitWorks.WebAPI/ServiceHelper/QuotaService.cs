// File: Services/QuotaService.cs
using System;
using System.Linq;
using System.Threading.Tasks;
using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Services
{
    public interface IQuotaService
    {
        /// <summary>
        /// Kiểm tra xem user có gói nào còn hạn và còn quota đăng tin hay không.
        /// Nếu có, sẽ trừ 1 RemainingJobPosts và trả về true; ngược lại trả về false.
        /// </summary>
        Task<bool> TryUseJobPostQuotaAsync(string idUser);

        /// <summary>
        /// Kiểm tra xem user có gói nào còn hạn và còn quota xem CV hay không.
        /// Nếu có, sẽ trừ 1 RemainingCvViews và trả về true; ngược lại trả về false.
        /// </summary>
        Task<bool> TryUseCvViewQuotaAsync(string idUser);
    }

    public class QuotaService : IQuotaService
    {
        private readonly JobConnectDbContext _context;

        public QuotaService(JobConnectDbContext context)
        {
            _context = context;
        }

        public async Task<bool> TryUseJobPostQuotaAsync(string idUser)
        {
            var now = DateTime.UtcNow;
            var transaction = await _context.JobTransactions
                .Where(tx =>
                    tx.IdUser == idUser &&
                    tx.ExpiryDate >= now &&
                    tx.RemainingJobPosts > 0)
                .OrderBy(tx => tx.ExpiryDate)
                .FirstOrDefaultAsync();

            if (transaction == null)
                return false;

            transaction.RemainingJobPosts -= 1;
            _context.JobTransactions.Update(transaction);

            var usageLog = new JobPostUsageLog
            {
                IdLog = Guid.NewGuid().ToString(),
                IdTransaction = transaction.IdTransaction,
                IdJobPost = null,
                UsedAt = now
            };
            _context.JobPostUsageLogs.Add(usageLog);

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> TryUseCvViewQuotaAsync(string idUser)
        {
            var now = DateTime.UtcNow;
            var transaction = await _context.JobTransactions
                .Where(tx =>
                    tx.IdUser == idUser &&
                    tx.ExpiryDate >= now &&
                    tx.RemainingCvViews > 0)
                .OrderBy(tx => tx.ExpiryDate)
                .FirstOrDefaultAsync();

            if (transaction == null)
                return false;

            transaction.RemainingCvViews -= 1;
            _context.JobTransactions.Update(transaction);

            var usageLog = new CvViewUsageLog
            {
                IdLog = Guid.NewGuid().ToString(),
                IdTransaction = transaction.IdTransaction,
                IdResume = null,
                UsedAt = now
            };
            _context.CvViewUsageLogs.Add(usageLog);

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
