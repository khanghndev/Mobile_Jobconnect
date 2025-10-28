using HuitWorks.WebAPI.DTOs;
using HuitWorks.WebAPI.Models;
using Microsoft.AspNetCore.Hosting;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System.Linq;
using System.Text.Json;

namespace HuitWorks.WebAPI.Services
{
    public interface ICvRenderService
    {
        Task<byte[]> RenderPdfAsync(CvDocumentDto document);
        Task<string> RenderHtmlAsync(CvDocumentDto document);
        Task<string> SavePdfToStorageAsync(byte[] pdfBytes, string fileName);
    }

    public class CvRenderService : ICvRenderService
    {
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<CvRenderService> _logger;

        public CvRenderService(IWebHostEnvironment environment, ILogger<CvRenderService> logger)
        {
            _environment = environment;
            _logger = logger;
            QuestPDF.Settings.License = LicenseType.Community;
        }

        public Task<byte[]> RenderPdfAsync(CvDocumentDto document)
        {
            try
            {
                var pdfDocument = Document.Create(documentContainer =>
                {
                    documentContainer.Page(page =>
                    {
                        page.Size(PageSizes.A4);
                        page.Margin(2, Unit.Centimetre);
                        page.PageColor(Colors.White);
                        page.DefaultTextStyle(x => x.FontSize(12));

                        // Render based on template engine
                        switch (document.Template?.Engine?.ToLower())
                        {
                            case "questpdf":
                                page.Content().Element(c => RenderQuestPdfTemplate(c, document));
                                break;
                            case "razor":
                                // For Razor templates, we would render HTML first then convert to PDF
                                page.Content().Element(c => RenderDefaultTemplate(c, document));
                                break;
                            default:
                                page.Content().Element(c => RenderDefaultTemplate(c, document));
                                break;
                        }
                    });
                });

                var bytes = pdfDocument.GeneratePdf();
                return Task.FromResult(bytes);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rendering PDF for document {DocumentId}", document.IdDocument);
                throw;
            }
        }

        public Task<string> RenderHtmlAsync(CvDocumentDto document)
        {
            try
            {
                var html = GenerateHtmlFromDocument(document);
                return Task.FromResult(html);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rendering HTML for document {DocumentId}", document.IdDocument);
                throw;
            }
        }

        public async Task<string> SavePdfToStorageAsync(byte[] pdfBytes, string fileName)
        {
            try
            {
                var webRootPath = _environment.WebRootPath;
                if (string.IsNullOrEmpty(webRootPath))
                {
                    webRootPath = Path.Combine(_environment.ContentRootPath, "wwwroot");
                }
                var uploadsPath = Path.Combine(webRootPath, "uploads", "cv");
                if (!Directory.Exists(uploadsPath))
                {
                    Directory.CreateDirectory(uploadsPath);
                }

                var filePath = Path.Combine(uploadsPath, fileName);
                await File.WriteAllBytesAsync(filePath, pdfBytes);

                var fileUrl = $"/uploads/cv/{fileName}";
                return fileUrl;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving PDF file {FileName}", fileName);
                throw;
            }
        }

        private void RenderQuestPdfTemplate(IContainer container, CvDocumentDto document)
        {
            container.Column(column =>
            {
                // Header section
                column.Item().PaddingBottom(20).Column(header =>
                {
                    if (document.Content?.PersonalInfo != null)
                    {
                        var personalInfo = document.Content.PersonalInfo;

                        header.Item().Text(personalInfo.FullName)
                            .FontSize(24)
                            .Bold()
                            .FontColor(Colors.Blue.Medium);

                        if (!string.IsNullOrEmpty(personalInfo.JobTitle))
                        {
                            header.Item().PaddingBottom(10).Text(personalInfo.JobTitle)
                                .FontSize(16)
                                .FontColor(Colors.Grey.Medium);
                        }

                        // Contact information
                        header.Item().Row(row =>
                        {
                            row.RelativeItem().Text($"📧 {personalInfo.Email}").FontSize(10);
                            if (!string.IsNullOrEmpty(personalInfo.Phone))
                            {
                                row.RelativeItem().Text($"📱 {personalInfo.Phone}").FontSize(10);
                            }
                        });

                        if (!string.IsNullOrEmpty(personalInfo.Address))
                        {
                            header.Item().Text($"📍 {personalInfo.Address}").FontSize(10);
                        }
                    }
                });

                // Professional Summary
                if (document.Content?.Summary?.ProfessionalSummary != null)
                {
                    column.Item().PaddingBottom(15).Column(summary =>
                    {
                        summary.Item().Text("Professional Summary")
                            .FontSize(16)
                            .Bold()
                            .FontColor(Colors.Blue.Medium);

                        summary.Item().Text(document.Content.Summary.ProfessionalSummary)
                            .FontSize(11)
                            .LineHeight(1.3f);
                    });
                }

                // Experience section
                if (document.Content?.Experiences?.Any() == true)
                {
                    column.Item().PaddingBottom(15).Column(experience =>
                    {
                        experience.Item().Text("Professional Experience")
                            .FontSize(16)
                            .Bold()
                            .FontColor(Colors.Blue.Medium);

                        foreach (var exp in document.Content.Experiences)
                        {
                            experience.Item().PaddingBottom(10).Column(expItem =>
                            {
                                expItem.Item().Row(row =>
                                {
                                    row.RelativeItem().Text(exp.Position)
                                        .Bold()
                                        .FontSize(12);
                                    row.AutoItem().Text($"{exp.StartDate:MMM yyyy} - {(exp.IsCurrent ? "Present" : exp.EndDate?.ToString("MMM yyyy"))}")
                                        .FontSize(10)
                                        .FontColor(Colors.Grey.Medium);
                                });

                                expItem.Item().Text(exp.Company)
                                    .FontSize(11)
                                    .FontColor(Colors.Grey.Medium);

                                if (!string.IsNullOrEmpty(exp.Location))
                                {
                                    expItem.Item().Text(exp.Location)
                                        .FontSize(10)
                                        .FontColor(Colors.Grey.Medium);
                                }

                                if (!string.IsNullOrEmpty(exp.Description))
                                {
                                    expItem.Item().PaddingTop(5).Text(exp.Description)
                                        .FontSize(10)
                                        .LineHeight(1.3f);
                                }

                                if (exp.Achievements?.Any() == true)
                                {
                                    expItem.Item().PaddingTop(5).Column(achievements =>
                                    {
                                        foreach (var achievement in exp.Achievements)
                                        {
                                            achievements.Item().PaddingLeft(10).Text($"• {achievement}")
                                                .FontSize(10);
                                        }
                                    });
                                }
                            });
                        }
                    });
                }

                // Education section
                if (document.Content?.Educations?.Any() == true)
                {
                    column.Item().PaddingBottom(15).Column(education =>
                    {
                        education.Item().Text("Education")
                            .FontSize(16)
                            .Bold()
                            .FontColor(Colors.Blue.Medium);

                        foreach (var edu in document.Content.Educations)
                        {
                            education.Item().PaddingBottom(8).Column(eduItem =>
                            {
                                eduItem.Item().Row(row =>
                                {
                                    row.RelativeItem().Text(edu.Degree)
                                        .Bold()
                                        .FontSize(12);
                                    row.AutoItem().Text($"{edu.StartDate:MMM yyyy} - {edu.EndDate?.ToString("MMM yyyy")}")
                                        .FontSize(10)
                                        .FontColor(Colors.Grey.Medium);
                                });

                                eduItem.Item().Text(edu.Institution)
                                    .FontSize(11)
                                    .FontColor(Colors.Grey.Medium);

                                if (!string.IsNullOrEmpty(edu.FieldOfStudy))
                                {
                                    eduItem.Item().Text(edu.FieldOfStudy)
                                        .FontSize(10);
                                }

                                if (edu.Gpa.HasValue)
                                {
                                    eduItem.Item().Text($"GPA: {edu.Gpa:F2}")
                                        .FontSize(10);
                                }
                            });
                        }
                    });
                }

                // Skills section
                if (document.Content?.Skills?.Any() == true)
                {
                    column.Item().PaddingBottom(15).Column(skills =>
                    {
                        skills.Item().Text("Skills")
                            .FontSize(16)
                            .Bold()
                            .FontColor(Colors.Blue.Medium);

                        var skillGroups = document.Content.Skills.GroupBy(s => s.Category ?? "General");
                        foreach (var group in skillGroups)
                        {
                            skills.Item().PaddingBottom(5).Column(skillGroup =>
                            {
                                skillGroup.Item().Text(group.Key)
                                    .Bold()
                                    .FontSize(11);

                                skillGroup.Item().PaddingLeft(10).Text(string.Join(", ", group.Select(s => s.Name)))
                                    .FontSize(10);
                            });
                        }
                    });
                }
            });
        }

        private void RenderDefaultTemplate(IContainer container, CvDocumentDto document)
        {
            // Fallback to QuestPDF template if no specific template is defined
            RenderQuestPdfTemplate(container, document);
        }

        private string GenerateHtmlFromDocument(CvDocumentDto document)
        {
            var html = $@"
<!DOCTYPE html>
<html lang=""{document.Locale}"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>{document.Title ?? "CV"}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }}
        .cv-container {{ max-width: 800px; margin: 0 auto; background: white; padding: 30px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }}
        .header {{ text-align: center; margin-bottom: 30px; border-bottom: 2px solid #007bff; padding-bottom: 20px; }}
        .name {{ font-size: 28px; font-weight: bold; color: #007bff; margin-bottom: 5px; }}
        .title {{ font-size: 18px; color: #666; margin-bottom: 15px; }}
        .contact {{ font-size: 14px; color: #555; }}
        .section {{ margin-bottom: 25px; }}
        .section-title {{ font-size: 18px; font-weight: bold; color: #007bff; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 5px; }}
        .item {{ margin-bottom: 15px; }}
        .item-title {{ font-weight: bold; font-size: 14px; }}
        .item-subtitle {{ color: #666; font-size: 13px; }}
        .item-date {{ color: #999; font-size: 12px; float: right; }}
        .item-description {{ margin-top: 5px; font-size: 13px; line-height: 1.4; }}
        .skills {{ display: flex; flex-wrap: wrap; gap: 10px; }}
        .skill {{ background: #f0f0f0; padding: 5px 10px; border-radius: 15px; font-size: 12px; }}
        ul {{ margin: 5px 0; padding-left: 20px; }}
        li {{ margin-bottom: 3px; font-size: 13px; }}
    </style>
</head>
<body>
    <div class=""cv-container"">
        <div class=""header"">
            <div class=""name"">{document.Content?.PersonalInfo?.FullName ?? ""}</div>
            <div class=""title"">{document.Content?.PersonalInfo?.JobTitle ?? ""}</div>
            <div class=""contact"">
                📧 {document.Content?.PersonalInfo?.Email ?? ""} | 
                📱 {document.Content?.PersonalInfo?.Phone ?? ""} | 
                📍 {document.Content?.PersonalInfo?.Address ?? ""}
            </div>
        </div>

        {(document.Content?.Summary?.ProfessionalSummary != null ? $@"
        <div class=""section"">
            <div class=""section-title"">Professional Summary</div>
            <div class=""item-description"">{document.Content.Summary.ProfessionalSummary}</div>
        </div>" : "")}

        {(document.Content?.Experiences?.Any() == true ? $@"
        <div class=""section"">
            <div class=""section-title"">Professional Experience</div>
            {string.Join("", document.Content.Experiences.Select(exp => $@"
            <div class=""item"">
                <div class=""item-title"">{exp.Position} <span class=""item-date"">{exp.StartDate:MMM yyyy} - {(exp.IsCurrent ? "Present" : exp.EndDate?.ToString("MMM yyyy"))}</span></div>
                <div class=""item-subtitle"">{exp.Company} - {exp.Location}</div>
                <div class=""item-description"">{exp.Description}</div>
                {(exp.Achievements?.Any() == true ? $@"
                <ul>
                    {string.Join("", exp.Achievements.Select(a => $"<li>{a}</li>"))}
                </ul>" : "")}
            </div>"))}
        </div>" : "")}

        {(document.Content?.Educations?.Any() == true ? $@"
        <div class=""section"">
            <div class=""section-title"">Education</div>
            {string.Join("", document.Content.Educations.Select(edu => $@"
            <div class=""item"">
                <div class=""item-title"">{edu.Degree} <span class=""item-date"">{edu.StartDate:MMM yyyy} - {edu.EndDate?.ToString("MMM yyyy")}</span></div>
                <div class=""item-subtitle"">{edu.Institution} - {edu.FieldOfStudy}</div>
                {(edu.Gpa.HasValue ? $"<div class=\"item-description\">GPA: {edu.Gpa:F2}</div>" : "")}
            </div>"))}
        </div>" : "")}

        {(document.Content?.Skills?.Any() == true ? $@"
        <div class=""section"">
            <div class=""section-title"">Skills</div>
            <div class=""skills"">
                {string.Join("", document.Content.Skills.Select(skill => $"<span class=\"skill\">{skill.Name}</span>"))}
            </div>
        </div>" : "")}
    </div>
</body>
</html>";

            return html;
        }
    }
}
