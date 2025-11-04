using HuitWorks.WebAPI.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace HuitWorks.WebAPI.Services
{
    public class OtpCleanupService : BackgroundService
    {
        private readonly IServiceScopeFactory _serviceScopeFactory;
        private readonly ILogger<OtpCleanupService> _logger;

        public OtpCleanupService(IServiceScopeFactory serviceScopeFactory, ILogger<OtpCleanupService> logger)
        {
            _serviceScopeFactory = serviceScopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using var scope = _serviceScopeFactory.CreateScope();
                    var context = scope.ServiceProvider.GetRequiredService<JobConnectDbContext>();

                    // Xóa OTP hết hạn (tên bảng là OtpCode, không phải OtpCodes)
                    var deletedOtps = await context.Database.ExecuteSqlRawAsync(
                        "DELETE FROM OtpCode WHERE ExpireAt < UTC_TIMESTAMP()",
                        cancellationToken: stoppingToken);

                    // Xóa pending registrations hết hạn
                    var deletedPending = await context.Database.ExecuteSqlRawAsync(
                        "DELETE FROM PendingRegistrations WHERE ExpireAt < UTC_TIMESTAMP()",
                        cancellationToken: stoppingToken);

                    if (deletedOtps > 0 || deletedPending > 0)
                    {
                        _logger.LogInformation($"Cleaned up {deletedOtps} expired OTPs and {deletedPending} expired pending registrations");
                    }

                    // Chờ 60 giây trước khi chạy lại
                    await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while cleaning up expired OTPs");
                    // Chờ 60 giây trước khi thử lại
                    await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
                }
            }
        }
    }
}

