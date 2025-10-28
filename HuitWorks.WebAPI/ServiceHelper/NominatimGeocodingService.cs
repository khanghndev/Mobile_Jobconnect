// File: Services/NominatimGeocodingService.cs
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web; // Cần cho HttpUtility.UrlEncode
using Microsoft.Extensions.Logging; // Để logging (tùy chọn nhưng nên có)

namespace HuitWorks.WebAPI.Services
{
    public class NominatimGeocodingService : IGeocodingService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<NominatimGeocodingService> _logger; // Tùy chọn

        // Base URL của Nominatim API
        private const string NominatimBaseUrl = "https://nominatim.openstreetmap.org/search";

        public NominatimGeocodingService(HttpClient httpClient, ILogger<NominatimGeocodingService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;

            // Cấu hình User-Agent, rất quan trọng với Nominatim
            // Thay "YourAppName/1.0 (yourcontact@example.com)" bằng thông tin ứng dụng của bạn
            _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("HuitWorksJobApp/1.0 (contact@huitworks.com)");
        }

        public async Task<Coordinates?> GetCoordinatesAsync(string address)
        {
            if (string.IsNullOrWhiteSpace(address))
            {
                return null;
            }

            // Encode địa chỉ để an toàn khi truyền qua URL
            string encodedAddress = HttpUtility.UrlEncode(address);
            // Thêm format=json và giới hạn kết quả là 1
            string requestUrl = $"{NominatimBaseUrl}?q={encodedAddress}&format=json&limit=1";

            try
            {
                _logger.LogInformation("Sending geocoding request to Nominatim: {Url}", requestUrl);
                HttpResponseMessage response = await _httpClient.GetAsync(requestUrl);

                if (response.IsSuccessStatusCode)
                {
                    string jsonResponse = await response.Content.ReadAsStringAsync();
                    _logger.LogDebug("Nominatim response: {JsonResponse}", jsonResponse);

                    // Parse JSON response
                    // Nominatim trả về một mảng các kết quả. Ta chỉ lấy phần tử đầu tiên.
                    var results = JsonSerializer.Deserialize<List<NominatimResult>>(jsonResponse, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    if (results != null && results.Count > 0)
                    {
                        var firstResult = results[0];
                        if (decimal.TryParse(firstResult.Lat, out decimal lat) &&
                            decimal.TryParse(firstResult.Lon, out decimal lon))
                        {
                            return new Coordinates { Latitude = lat, Longitude = lon };
                        }
                        _logger.LogWarning("Could not parse lat/lon from Nominatim result for address: {Address}", address);
                    }
                    else
                    {
                        _logger.LogWarning("No geocoding results found for address: {Address}", address);
                    }
                }
                else
                {
                    _logger.LogError("Nominatim API request failed with status code {StatusCode} for address: {Address}. Response: {ResponseContent}",
                        response.StatusCode, address, await response.Content.ReadAsStringAsync());
                }
            }
            catch (JsonException jsonEx)
            {
                _logger.LogError(jsonEx, "Error deserializing Nominatim JSON response for address: {Address}", address);
            }
            catch (HttpRequestException httpEx)
            {
                _logger.LogError(httpEx, "HTTP request error during geocoding for address: {Address}", address);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred during geocoding for address: {Address}", address);
            }

            return null;
        }

        // Class để deserialize kết quả từ Nominatim
        private class NominatimResult
        {
            public string? Place_id { get; set; }
            public string? Licence { get; set; }
            public string? Osm_type { get; set; }
            public long? Osm_id { get; set; }
            public List<string>? Boundingbox { get; set; }
            public string? Lat { get; set; } // Nominatim trả về lat/lon dưới dạng string
            public string? Lon { get; set; }
            public string? Display_name { get; set; }
            public string? Class { get; set; }
            public string? Type { get; set; }
            public double? Importance { get; set; }
            public string? Icon { get; set; }
        }
    }
}