// File: Services/IGeocodingService.cs (hoặc một thư mục phù hợp)
namespace HuitWorks.WebAPI.Services
{
    public class Coordinates
    {
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
    }

    public interface IGeocodingService
    {
        Task<Coordinates?> GetCoordinatesAsync(string address);
    }
}