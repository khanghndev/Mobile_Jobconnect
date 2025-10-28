using HuitWorks.WebAPI.Models;
namespace HuitWorks.WebAPI.DTOs
{
    public class AuthResponseDTO
    {
        public string Token { get; set; } = null!;
        public User User { get; set; } = null!;
        public bool NeedProfile { get; set; }
    }
}