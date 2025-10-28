using HuitWorks.WebAPI.DTOs;

namespace HuitWorks.WebAPI.Services
{
    public interface IAppwriteSpatialService
    {
        /// <summary>
        /// Find jobs within a specified radius from a point using Appwrite spatial queries
        /// This method will use Appwrite's distanceLessThan query operator
        /// </summary>
        /// <param name="request">Nearby jobs request with coordinates and radius</param>
        /// <returns>List of jobs with distance information</returns>
        Task<IEnumerable<JobPostingWithDistanceDto>> GetNearbyJobsUsingAppwriteAsync(NearbyJobsRequestDto request);

        /// <summary>
        /// Find jobs within a polygon area using Appwrite spatial queries
        /// This method will use Appwrite's intersects query operator
        /// </summary>
        /// <param name="request">Area jobs request with polygon coordinates</param>
        /// <returns>List of jobs within the area</returns>
        Task<IEnumerable<JobPostingDto>> GetJobsInAreaUsingAppwriteAsync(AreaJobsRequestDto request);

        /// <summary>
        /// Create a point geometry for Appwrite spatial queries
        /// </summary>
        /// <param name="latitude">Latitude</param>
        /// <param name="longitude">Longitude</param>
        /// <returns>Point geometry string for Appwrite</returns>
        string CreatePointGeometry(decimal latitude, decimal longitude);

        /// <summary>
        /// Create a polygon geometry for Appwrite spatial queries
        /// </summary>
        /// <param name="points">List of points forming the polygon</param>
        /// <returns>Polygon geometry string for Appwrite</returns>
        string CreatePolygonGeometry(List<PointDto> points);

        /// <summary>
        /// Create a circle geometry for radius-based queries
        /// </summary>
        /// <param name="centerLatitude">Center latitude</param>
        /// <param name="centerLongitude">Center longitude</param>
        /// <param name="radiusKm">Radius in kilometers</param>
        /// <returns>Circle geometry string for Appwrite</returns>
        string CreateCircleGeometry(decimal centerLatitude, decimal centerLongitude, decimal radiusKm);
    }
}
