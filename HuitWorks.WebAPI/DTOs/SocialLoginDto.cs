using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace HuitWorks.WebAPI.DTOs
{
    public class SocialLoginDto
    {
        [Required]
        [JsonPropertyName("idToken")]
        public string IdToken { get; set; } = null!;

        [Required]
        [EmailAddress]
        [JsonPropertyName("email")]
        public string Email { get; set; } = null!;

        [Required]
        [JsonPropertyName("name")]
        public string Name { get; set; } = null!;

        [JsonPropertyName("roleName")]
        public string? RoleName { get; set; }
    }
}
