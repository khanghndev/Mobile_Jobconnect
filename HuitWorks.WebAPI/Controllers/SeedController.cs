using HuitWorks.WebAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace HuitWorks.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SeedController : ControllerBase
    {
        private readonly ICvTemplateSeedService _seedService;
        private readonly ILogger<SeedController> _logger;

        public SeedController(ICvTemplateSeedService seedService, ILogger<SeedController> logger)
        {
            _seedService = seedService;
            _logger = logger;
        }

        [HttpPost("cv-templates")]
        public async Task<IActionResult> SeedCvTemplates()
        {
            try
            {
                await _seedService.SeedTemplatesAsync();
                return Ok(new { message = "CV templates seeded successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error seeding CV templates");
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
