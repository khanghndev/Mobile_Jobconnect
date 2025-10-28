using HuitWorks.WebAPI.Models;

namespace HuitWorks.WebAPI.DTOs
{
    public class CvTemplateDto
    {
        public string IdTemplate { get; set; } = string.Empty;
        public string Slug { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Engine { get; set; } = "Razor";
        public string? PreviewUrl { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CvDocumentDto
    {
        public string IdDocument { get; set; } = string.Empty;
        public string IdUser { get; set; } = string.Empty;
        public string IdTemplate { get; set; } = string.Empty;
        public string? Title { get; set; }
        public string Locale { get; set; } = "vi-VN";
        public string? ColorScheme { get; set; }
        public CvContentDto? Content { get; set; }
        public CvDocumentStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public CvTemplateDto? Template { get; set; }
    }

    public class CreateCvDocumentDto
    {
        public string IdTemplate { get; set; } = string.Empty;
        public string? Title { get; set; }
        public string Locale { get; set; } = "vi-VN";
        public string? ColorScheme { get; set; }
        public CvContentDto Content { get; set; } = new CvContentDto();
    }

    public class UpdateCvDocumentDto
    {
        public string? Title { get; set; }
        public string? ColorScheme { get; set; }
        public CvContentDto? Content { get; set; }
        public CvDocumentStatus? Status { get; set; }
    }

    public class CvContentDto
    {
        public CvPersonalInfoDto? PersonalInfo { get; set; }
        public List<CvExperienceDto> Experiences { get; set; } = new List<CvExperienceDto>();
        public List<CvEducationDto> Educations { get; set; } = new List<CvEducationDto>();
        public List<CvSkillDto> Skills { get; set; } = new List<CvSkillDto>();
        public List<CvProjectDto> Projects { get; set; } = new List<CvProjectDto>();
        public List<CvCertificationDto> Certifications { get; set; } = new List<CvCertificationDto>();
        public List<CvLanguageDto> Languages { get; set; } = new List<CvLanguageDto>();
        public CvSummaryDto? Summary { get; set; }
    }

    public class CvPersonalInfoDto
    {
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public string? LinkedIn { get; set; }
        public string? GitHub { get; set; }
        public string? Website { get; set; }
        public string? Avatar { get; set; }
        public string? JobTitle { get; set; }
    }

    public class CvExperienceDto
    {
        public string Company { get; set; } = string.Empty;
        public string Position { get; set; } = string.Empty;
        public string? Location { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool IsCurrent { get; set; }
        public string? Description { get; set; }
        public List<string> Achievements { get; set; } = new List<string>();
    }

    public class CvEducationDto
    {
        public string Institution { get; set; } = string.Empty;
        public string Degree { get; set; } = string.Empty;
        public string? FieldOfStudy { get; set; }
        public string? Location { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public decimal? Gpa { get; set; }
        public string? Description { get; set; }
    }

    public class CvSkillDto
    {
        public string Name { get; set; } = string.Empty;
        public string Level { get; set; } = string.Empty; // Beginner, Intermediate, Advanced, Expert
        public string? Category { get; set; }
    }

    public class CvProjectDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Technologies { get; set; }
        public string? Url { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public List<string> Features { get; set; } = new List<string>();
    }

    public class CvCertificationDto
    {
        public string Name { get; set; } = string.Empty;
        public string Issuer { get; set; } = string.Empty;
        public DateTime IssueDate { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public string? CredentialId { get; set; }
        public string? CredentialUrl { get; set; }
    }

    public class CvLanguageDto
    {
        public string Name { get; set; } = string.Empty;
        public string Proficiency { get; set; } = string.Empty; // Native, Fluent, Intermediate, Basic
    }

    public class CvSummaryDto
    {
        public string? ProfessionalSummary { get; set; }
        public string? Objective { get; set; }
    }

    public class CvExportDto
    {
        public string IdExport { get; set; } = string.Empty;
        public string IdDocument { get; set; } = string.Empty;
        public CvExportFormat Format { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public int? FileSizeKB { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateCvExportDto
    {
        public string IdDocument { get; set; } = string.Empty;
        public CvExportFormat Format { get; set; } = CvExportFormat.Pdf;
    }

    public class CvShareLinkDto
    {
        public string IdShare { get; set; } = string.Empty;
        public string IdDocument { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public CvShareAccessLevel AccessLevel { get; set; }
        public DateTime? ExpireAt { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public string ShareUrl { get; set; } = string.Empty;
    }

    public class CreateCvShareLinkDto
    {
        public string IdDocument { get; set; } = string.Empty;
        public CvShareAccessLevel AccessLevel { get; set; } = CvShareAccessLevel.View;
        public DateTime? ExpireAt { get; set; }
    }
}
