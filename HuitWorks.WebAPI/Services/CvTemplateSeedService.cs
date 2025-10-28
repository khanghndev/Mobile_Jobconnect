using HuitWorks.WebAPI.Data;
using HuitWorks.WebAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HuitWorks.WebAPI.Services
{
    public interface ICvTemplateSeedService
    {
        Task SeedTemplatesAsync();
    }

    public class CvTemplateSeedService : ICvTemplateSeedService
    {
        private readonly JobConnectDbContext _context;

        public CvTemplateSeedService(JobConnectDbContext context)
        {
            _context = context;
        }

        public async Task SeedTemplatesAsync()
        {
            if (await _context.CvTemplates.AnyAsync())
            {
                return; // Already seeded
            }

            var templates = new List<CvTemplate>
            {
                new CvTemplate
                {
                    IdTemplate = Guid.NewGuid().ToString(),
                    Slug = "modern",
                    Name = "Modern Template",
                    Engine = "QuestPdf",
                    PreviewUrl = "https://via.placeholder.com/320x420?text=Modern+CV",
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                },
                new CvTemplate
                {
                    IdTemplate = Guid.NewGuid().ToString(),
                    Slug = "classic",
                    Name = "Classic Template",
                    Engine = "QuestPdf",
                    PreviewUrl = "https://via.placeholder.com/320x420?text=Classic+CV",
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                },
                new CvTemplate
                {
                    IdTemplate = Guid.NewGuid().ToString(),
                    Slug = "creative",
                    Name = "Creative Template",
                    Engine = "QuestPdf",
                    PreviewUrl = "https://via.placeholder.com/320x420?text=Creative+CV",
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                },
                new CvTemplate
                {
                    IdTemplate = Guid.NewGuid().ToString(),
                    Slug = "minimal",
                    Name = "Minimal Template",
                    Engine = "QuestPdf",
                    PreviewUrl = "https://via.placeholder.com/320x420?text=Minimal+CV",
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                }
            };

            _context.CvTemplates.AddRange(templates);
            await _context.SaveChangesAsync();
        }
    }
}
