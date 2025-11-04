using Microsoft.EntityFrameworkCore;
using HuitWorks.WebAPI.Data;
using System.Text;
using System.Text.Json;

namespace HuitWorks.WebAPI.Services
{
    public class PushNotificationService : IPushNotificationService
    {
        private readonly JobConnectDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;

        public PushNotificationService(JobConnectDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
            _httpClient = new HttpClient();
        }

        public async Task<bool> SendPushNotificationAsync(string deviceToken, string title, string body, Dictionary<string, string>? data = null)
        {
            try
            {
                var serverKey = _configuration["Firebase:ServerKey"];
                if (string.IsNullOrWhiteSpace(serverKey))
                {
                    Console.WriteLine("[PushNotification] Firebase ServerKey not configured");
                    return false;
                }

                var payload = new
                {
                    to = deviceToken,
                    notification = new
                    {
                        title = title,
                        body = body,
                        sound = "default"
                    },
                    data = data ?? new Dictionary<string, string>(),
                    priority = "high"
                };

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                _httpClient.DefaultRequestHeaders.Clear();
                _httpClient.DefaultRequestHeaders.Add("Authorization", $"key={serverKey}");

                var response = await _httpClient.PostAsync("https://fcm.googleapis.com/fcm/send", content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[PushNotification] Successfully sent to token: {deviceToken.Substring(0, Math.Min(20, deviceToken.Length))}...");
                    return true;
                }
                else
                {
                    Console.WriteLine($"[PushNotification] Failed to send: {response.StatusCode} - {responseContent}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[PushNotification] Exception: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendPushNotificationToUserAsync(string userId, string title, string body, Dictionary<string, string>? data = null)
        {
            var deviceTokens = await _context.DeviceTokens
                .Where(dt => dt.IdUser == userId)
                .Select(dt => dt.Token)
                .ToListAsync();

            if (!deviceTokens.Any())
            {
                Console.WriteLine($"[PushNotification] No device tokens found for user: {userId}");
                return false;
            }

            bool allSuccess = true;
            foreach (var token in deviceTokens)
            {
                var result = await SendPushNotificationAsync(token, title, body, data);
                if (!result)
                    allSuccess = false;
            }

            return allSuccess;
        }

        public async Task<bool> SendPushNotificationToMultipleUsersAsync(List<string> userIds, string title, string body, Dictionary<string, string>? data = null)
        {
            var deviceTokens = await _context.DeviceTokens
                .Where(dt => userIds.Contains(dt.IdUser))
                .Select(dt => dt.Token)
                .Distinct()
                .ToListAsync();

            if (!deviceTokens.Any())
            {
                Console.WriteLine($"[PushNotification] No device tokens found for users");
                return false;
            }

            bool allSuccess = true;
            foreach (var token in deviceTokens)
            {
                var result = await SendPushNotificationAsync(token, title, body, data);
                if (!result)
                    allSuccess = false;
            }

            return allSuccess;
        }
    }
}

