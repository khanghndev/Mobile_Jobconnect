using System.Text.Json.Serialization;

namespace HuitWorks.WebAPI.DTOs
{
    public class SocialLoginResponseDto
    {
        [JsonPropertyName("token")]
        public string Token { get; set; } = null!;

        [JsonPropertyName("user")]
        public UserDto User { get; set; } = null!;

        [JsonPropertyName("needProfile")]
        public bool NeedProfile { get; set; }
    }
}
