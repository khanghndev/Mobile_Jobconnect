namespace HuitWorks.WebAPI.Services
{
    public interface IPushNotificationService
    {
        Task<bool> SendPushNotificationAsync(string deviceToken, string title, string body, Dictionary<string, string>? data = null);
        Task<bool> SendPushNotificationToUserAsync(string userId, string title, string body, Dictionary<string, string>? data = null);
        Task<bool> SendPushNotificationToMultipleUsersAsync(List<string> userIds, string title, string body, Dictionary<string, string>? data = null);
    }
}

