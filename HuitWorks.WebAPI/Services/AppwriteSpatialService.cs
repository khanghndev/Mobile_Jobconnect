using HuitWorks.WebAPI.DTOs;
using System.Text.Json;

namespace HuitWorks.WebAPI.Services
{
    public class AppwriteSpatialService : IAppwriteSpatialService
    {
        private readonly ILogger<AppwriteSpatialService> _logger;

        public AppwriteSpatialService(ILogger<AppwriteSpatialService> logger)
        {
            _logger = logger;
        }

        public async Task<IEnumerable<JobPostingWithDistanceDto>> GetNearbyJobsUsingAppwriteAsync(NearbyJobsRequestDto request)
        {
            try
            {
                // This is a placeholder implementation
                // In a real Appwrite integration, you would use the Appwrite SDK
                // to perform spatial queries using the distanceLessThan operator
                
                _logger.LogInformation("Appwrite spatial query for nearby jobs: lat={Latitude}, lon={Longitude}, radius={Radius}km", 
                    request.Latitude, request.Longitude, request.RadiusKm);

                // Example of how you would structure the Appwrite query:
                /*
                var appwrite = new Client()
                    .SetEndpoint("https://cloud.appwrite.io/v1")
                    .SetProject("your-project-id");

                var databases = new Databases(appwrite);

                var result = await databases.ListDocuments(
                    databaseId: "JobConnectDatabase",
                    collectionId: "jobPosting",
                    queries: new List<string>
                    {
                        Query.equal("postStatus", "open"),
                        Query.distanceLessThan("location", 
                            CreatePointGeometry(request.Latitude, request.Longitude), 
                            request.RadiusKm * 1000) // Convert km to meters
                    }
                );
                */

                // For now, return empty list as this requires actual Appwrite integration
                return new List<JobPostingWithDistanceDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Appwrite spatial query for nearby jobs");
                throw;
            }
        }

        public async Task<IEnumerable<JobPostingDto>> GetJobsInAreaUsingAppwriteAsync(AreaJobsRequestDto request)
        {
            try
            {
                _logger.LogInformation("Appwrite spatial query for area jobs with {PointCount} polygon points", 
                    request.Polygon.Count);

                // Example of how you would structure the Appwrite query:
                /*
                var appwrite = new Client()
                    .SetEndpoint("https://cloud.appwrite.io/v1")
                    .SetProject("your-project-id");

                var databases = new Databases(appwrite);

                var result = await databases.ListDocuments(
                    databaseId: "JobConnectDatabase",
                    collectionId: "jobPosting",
                    queries: new List<string>
                    {
                        Query.equal("postStatus", "open"),
                        Query.intersects("location", CreatePolygonGeometry(request.Polygon))
                    }
                );
                */

                // For now, return empty list as this requires actual Appwrite integration
                return new List<JobPostingDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Appwrite spatial query for area jobs");
                throw;
            }
        }

        public string CreatePointGeometry(decimal latitude, decimal longitude)
        {
            // Create a GeoJSON Point geometry for Appwrite
            var point = new
            {
                type = "Point",
                coordinates = new[] { (double)longitude, (double)latitude }
            };

            return JsonSerializer.Serialize(point);
        }

        public string CreatePolygonGeometry(List<PointDto> points)
        {
            // Create a GeoJSON Polygon geometry for Appwrite
            var coordinates = points.Select(p => new[] { (double)p.Longitude, (double)p.Latitude }).ToList();
            
            // Ensure the polygon is closed (first and last points are the same)
            if (coordinates.Count > 0 && 
                (coordinates[0][0] != coordinates[coordinates.Count - 1][0] || 
                 coordinates[0][1] != coordinates[coordinates.Count - 1][1]))
            {
                coordinates.Add(coordinates[0]);
            }

            var polygon = new
            {
                type = "Polygon",
                coordinates = new[] { coordinates }
            };

            return JsonSerializer.Serialize(polygon);
        }

        public string CreateCircleGeometry(decimal centerLatitude, decimal centerLongitude, decimal radiusKm)
        {
            // Create a circle using a polygon approximation
            // This creates a 32-sided polygon that approximates a circle
            var points = new List<PointDto>();
            var radiusInDegrees = radiusKm / 111.32m; // Approximate conversion from km to degrees

            for (int i = 0; i < 32; i++)
            {
                var angle = (decimal)(2 * Math.PI * i / 32);
                var lat = centerLatitude + radiusInDegrees * (decimal)Math.Cos((double)angle);
                var lon = centerLongitude + radiusInDegrees * (decimal)Math.Sin((double)angle) / (decimal)Math.Cos((double)centerLatitude * Math.PI / 180);

                points.Add(new PointDto
                {
                    Latitude = lat,
                    Longitude = lon
                });
            }

            return CreatePolygonGeometry(points);
        }
    }
}
