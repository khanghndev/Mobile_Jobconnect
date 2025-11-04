using Microsoft.Extensions.Configuration;
using System.Text;
using System.Text.Json;

namespace HuitWorks.WebAPI.Services
{
    public interface ISupabaseAuthService
    {
        Task<(bool success, string? userId, string? email, string? name, string? avatar, string? error)> VerifySupabaseJwtAsync(string jwt);
        Task<(bool success, string? userId, string? error)> CreateUserAsync(string email, string password, string? name = null, string? phone = null);
        Task SendEmailVerificationAsync(string userId, string redirectUrl);
        Task<bool> DeleteUserAsync(string userId);
        Task SendEmailAsync(string to, string subject, string htmlBody);
        Task<bool> UpdatePasswordAsync(string userId, string newPassword);
    }

    public class SupabaseAuthService : ISupabaseAuthService
    {
        private readonly IConfiguration _configuration;
        private readonly string _supabaseUrl;
        private readonly string _serviceRoleKey;

        public SupabaseAuthService(IConfiguration configuration)
        {
            _configuration = configuration;
            _supabaseUrl = (_configuration["Supabase:Url"] ?? "").TrimEnd('/');
            _serviceRoleKey = _configuration["Supabase:ServiceRoleKey"] ?? "";
        }

        private HttpClient CreateHttpClient()
        {
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("apikey", _serviceRoleKey);
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_serviceRoleKey}");
            return httpClient;
        }

        public async Task<(bool success, string? userId, string? email, string? name, string? avatar, string? error)> VerifySupabaseJwtAsync(string jwt)
        {
            try
            {
                var supabaseUrl = _configuration["Supabase:Url"];
                if (string.IsNullOrWhiteSpace(supabaseUrl))
                {
                    return (false, null, null, null, null, "Supabase URL not configured");
                }

                // Call Supabase REST API to get user info using the JWT
                using var httpClient = new HttpClient();
                httpClient.DefaultRequestHeaders.Add("apikey", _configuration["Supabase:ServiceRoleKey"]);
                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {jwt}");
                
                var response = await httpClient.GetAsync($"{supabaseUrl.TrimEnd('/')}/auth/v1/user");
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorBody = await response.Content.ReadAsStringAsync();
                    return (false, null, null, null, null, $"Supabase API error: {(int)response.StatusCode} {errorBody}");
                }

                var body = await response.Content.ReadAsStringAsync();
                using var doc = System.Text.Json.JsonDocument.Parse(body);
                var root = doc.RootElement;

                var userId = root.TryGetProperty("id", out var idProp) ? idProp.GetString() : null;
                var email = root.TryGetProperty("email", out var emailProp) ? emailProp.GetString() : null;
                
                if (string.IsNullOrWhiteSpace(userId))
                {
                    return (false, null, null, null, null, "Missing user id in Supabase response");
                }

                // Extract name from user_metadata
                string? name = null;
                if (root.TryGetProperty("user_metadata", out var userMeta) && userMeta.ValueKind == System.Text.Json.JsonValueKind.Object)
                {
                    if (userMeta.TryGetProperty("name", out var nameProp))
                        name = nameProp.GetString();
                    else if (userMeta.TryGetProperty("full_name", out var fullNameProp))
                        name = fullNameProp.GetString();
                }

                // Extract avatar from user_metadata
                string? avatar = null;
                if (root.TryGetProperty("user_metadata", out var userMeta2) && userMeta2.ValueKind == System.Text.Json.JsonValueKind.Object)
                {
                    if (userMeta2.TryGetProperty("avatar_url", out var avatarProp))
                        avatar = avatarProp.GetString();
                    else if (userMeta2.TryGetProperty("picture", out var pictureProp))
                        avatar = pictureProp.GetString();
                }

                // Also check app_metadata for avatar
                if (string.IsNullOrWhiteSpace(avatar) && root.TryGetProperty("app_metadata", out var appMeta) && appMeta.ValueKind == System.Text.Json.JsonValueKind.Object)
                {
                    if (appMeta.TryGetProperty("avatar_url", out var appAvatarProp))
                        avatar = appAvatarProp.GetString();
                }

                return (true, userId, email, name, avatar, null);
            }
            catch (Exception ex)
            {
                return (false, null, null, null, null, ex.Message);
            }
        }

        public async Task<(bool success, string? userId, string? error)> CreateUserAsync(string email, string password, string? name = null, string? phone = null)
        {
            try
            {
                using var httpClient = CreateHttpClient();

                var payload = new Dictionary<string, object?>
                {
                    ["email"] = email,
                    ["password"] = password,
                    ["email_confirm"] = false
                };

                var userMetadata = new Dictionary<string, object?>();
                if (!string.IsNullOrWhiteSpace(name))
                {
                    userMetadata["name"] = name;
                }

                if (!string.IsNullOrWhiteSpace(phone))
                {
                    userMetadata["phone"] = phone;
                    payload["phone"] = phone;
                }

                if (userMetadata.Count > 0)
                {
                    payload["user_metadata"] = userMetadata;
                }

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await httpClient.PostAsync($"{_supabaseUrl}/auth/v1/admin/users", content);
                var body = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    using var doc = JsonDocument.Parse(body);
                    var userId = doc.RootElement.TryGetProperty("id", out var idProp) ? idProp.GetString() : null;
                    if (!string.IsNullOrWhiteSpace(userId))
                    {
                        return (true, userId, null);
                    }
                    return (false, null, "Failed to create user: missing user id in response");
                }

                // If user already exists, try to find the user
                if ((int)response.StatusCode == 422 || body.Contains("already registered") || body.Contains("already exists"))
                {
                    var (foundId, searchErr) = await TryFindUserIdByEmail(email);
                    if (!string.IsNullOrWhiteSpace(foundId))
                        return (true, foundId, null);

                    return (false, null, searchErr ?? body);
                }

                return (false, null, body);
            }
            catch (Exception ex)
            {
                return (false, null, ex.Message);
            }
        }

        private async Task<(string? id, string? error)> TryFindUserIdByEmail(string email)
        {
            try
            {
                using var httpClient = CreateHttpClient();

                // List users và tìm theo email
                var url = $"{_supabaseUrl}/auth/v1/admin/users?per_page=1000";

                using var res = await httpClient.GetAsync(url);
                var body = await res.Content.ReadAsStringAsync();

                if (!res.IsSuccessStatusCode)
                    return (null, body);

                using var doc = JsonDocument.Parse(body);
                if (doc.RootElement.TryGetProperty("users", out var arr) && arr.ValueKind == JsonValueKind.Array)
                {
                    foreach (var userEl in arr.EnumerateArray())
                    {
                        var em = userEl.TryGetProperty("email", out var e) ? e.GetString() : null;
                        if (!string.Equals(em, email, StringComparison.OrdinalIgnoreCase)) continue;

                        var id = userEl.TryGetProperty("id", out var idp) ? idp.GetString() : null;
                        if (!string.IsNullOrWhiteSpace(id))
                            return (id, null);
                    }
                }
                return (null, "Không tìm thấy user theo email.");
            }
            catch (Exception ex)
            {
                return (null, $"Parse search response failed: {ex.Message}");
            }
        }

        public async Task SendEmailVerificationAsync(string userId, string redirectUrl)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userId)) return;

                using var httpClient = CreateHttpClient();

                // Send verification email using admin API
                var payload = new Dictionary<string, object?>
                {
                    ["type"] = "signup",
                    ["email_redirect_to"] = redirectUrl
                };

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                await httpClient.PostAsync(
                    $"{_supabaseUrl}/auth/v1/admin/users/{Uri.EscapeDataString(userId)}/resend",
                    content);
            }
            catch (Exception)
            {
                // Silently fail - don't block registration flow
            }
        }

        public async Task<bool> DeleteUserAsync(string userId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userId)) return false;

                using var httpClient = CreateHttpClient();
                var response = await httpClient.DeleteAsync($"{_supabaseUrl}/auth/v1/admin/users/{Uri.EscapeDataString(userId)}");
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task SendEmailAsync(string to, string subject, string htmlBody)
        {
            try
            {
                var smtpSection = _configuration.GetSection("Smtp");
                var host = smtpSection["Host"];
                var port = int.TryParse(smtpSection["Port"], out var p) ? p : 587;
                var user = smtpSection["Username"];
                var pass = smtpSection["Password"];
                var from = smtpSection["From"] ?? user;
                var enableSsl = bool.TryParse(smtpSection["EnableSsl"], out var ssl) ? ssl : true;

                if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(user) || string.IsNullOrWhiteSpace(pass))
                    throw new Exception("SMTP configuration missing or incomplete");

                using var client = new System.Net.Mail.SmtpClient(host, port)
                {
                    EnableSsl = enableSsl,
                    Credentials = new System.Net.NetworkCredential(user, pass)
                };

                var mail = new System.Net.Mail.MailMessage
                {
                    From = new System.Net.Mail.MailAddress(from, "HuitWorks Support"),
                    Subject = subject,
                    Body = htmlBody,
                    IsBodyHtml = true
                };

                mail.To.Add(to);

                await client.SendMailAsync(mail);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SendEmailAsync] Failed to send email: {ex.Message}");
                throw new Exception("Gửi email thất bại: " + ex.Message);
            }
        }

        /// <summary>
        /// Cập nhật mật khẩu của user trên Supabase
        /// </summary>
        public async Task<bool> UpdatePasswordAsync(string userId, string newPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(newPassword))
                    return false;

                using var httpClient = CreateHttpClient();

                var payload = new Dictionary<string, object?>
                {
                    ["password"] = newPassword
                };

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await httpClient.PutAsync(
                    $"{_supabaseUrl}/auth/v1/admin/users/{Uri.EscapeDataString(userId)}",
                    content);

                return response.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UpdatePasswordAsync] Failed to update password: {ex.Message}");
                return false;
            }
        }

    }
}

