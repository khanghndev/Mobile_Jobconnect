using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("companies")]
    public class Company
    {
        [Key]
        [Column("idCompany")]
        public required string IdCompany { get; set; }

        [Column("companyName")]
        public required string CompanyName { get; set; }

        [Column("taxCode")]
        public required string? TaxCode { get; set; }

        [Column("address")]
        public required string? Address { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("logoCompany")]
        public string? LogoCompany { get; set; }

        [Column("websiteUrl")]
        public string? WebsiteUrl { get; set; }

        [Column("industry")]
        public required string? Industry { get; set; }

        [Column("scale")]
        public required string? Scale { get; set; }

        [Column("businessLicenseUrl")]
        public string? BusinessLicenseUrl { get; set; }

        [Column("status")]
        public required string? Status { get; set; }

        [Column("isFeatured")]
        public required int IsFeatured { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; }

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}
