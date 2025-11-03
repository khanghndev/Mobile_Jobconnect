using System;

namespace HuitWorks.WebAPI.Models
{
    public class DeviceToken
    {
        public string Id { get; set; }
        public string IdUser { get; set; }
        public string Token { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
