using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Services
{
    public interface ISpatialQueryService
    {
        /// <summary>
        /// Find jobs within a specified radius from a point
        /// </summary>
        /// <param name="request">Nearby jobs request with coordinates and radius</param>
        /// <returns>List of jobs with distance information</returns>
        Task<IEnumerable<JobPostingWithDistanceDto>> GetNearbyJobsAsync(NearbyJobsRequestDto request);

        /// <summary>
        /// Find jobs within a polygon area
        /// </summary>
        /// <param name="request">Area jobs request with polygon coordinates</param>
        /// <returns>List of jobs within the area</returns>
        Task<IEnumerable<JobPostingDto>> GetJobsInAreaAsync(AreaJobsRequestDto request);

        /// <summary>
        /// Calculate distance between two points using Haversine formula
        /// </summary>
        /// <param name="lat1">Latitude of first point</param>
        /// <param name="lon1">Longitude of first point</param>
        /// <param name="lat2">Latitude of second point</param>
        /// <param name="lon2">Longitude of second point</param>
        /// <returns>Distance in kilometers</returns>
        decimal CalculateDistance(decimal lat1, decimal lon1, decimal lat2, decimal lon2);

        /// <summary>
        /// Check if a point is inside a polygon using ray casting algorithm
        /// </summary>
        /// <param name="pointLat">Point latitude</param>
        /// <param name="pointLon">Point longitude</param>
        /// <param name="polygon">Polygon coordinates</param>
        /// <returns>True if point is inside polygon</returns>
        bool IsPointInPolygon(decimal pointLat, decimal pointLon, List<PointDto> polygon);
    }
}
