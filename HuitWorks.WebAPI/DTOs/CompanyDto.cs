using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class CreateCompanyDto
    {
        //[Required(ErrorMessage = "Tên công ty là bắt buộc.")]
        //[StringLength(100, ErrorMessage = "Tên công ty không được vượt quá 100 ký tự.")]
        public string CompanyName { get; set; } = null!;

        //[Required(ErrorMessage = "Mã số thuế là bắt buộc.")]
        //[StringLength(50, ErrorMessage = "Mã số thuế không được vượt quá 50 ký tự.")]
        public string TaxCode { get; set; } = null!;

        //[Required(ErrorMessage = "Địa chỉ là bắt buộc.")]
        //[StringLength(255, ErrorMessage = "Địa chỉ không được vượt quá 255 ký tự.")]
        public string Address { get; set; } = null!;

        //[StringLength(255, ErrorMessage = "Mô tả không được vượt quá 255 ký tự.")]
        public string? Description { get; set; }

        //[StringLength(255, ErrorMessage = "LogoCompany không được vượt quá 255 ký tự.")]
        public string? LogoCompany { get; set; }

        //[StringLength(255, ErrorMessage = "WebsiteUrl không được vượt quá 255 ký tự.")]
        //[Url(ErrorMessage = "WebsiteUrl phải là một URL hợp lệ.")]
        public string? WebsiteUrl { get; set; }

        //[Required(ErrorMessage = "Quy mô công ty là bắt buộc.")]
        //[StringLength(100, ErrorMessage = "Quy mô công ty không được vượt quá 100 ký tự.")]
        public string Scale { get; set; } = null!;

        //[Required(ErrorMessage = "Ngành nghề là bắt buộc.")]
        //[StringLength(100, ErrorMessage = "Ngành nghề không được vượt quá 100 ký tự.")]
        public string Industry { get; set; } = null!;

        //[StringLength(255, ErrorMessage = "Link giấy phép kinh doanh không được vượt quá 255 ký tự.")]
        //[Url(ErrorMessage = "BusinessLicenseUrl phải là một URL hợp lệ.")]
        public string? BusinessLicenseUrl { get; set; }

        //[RegularExpression("^(active|inactive|suspended)$", ErrorMessage = "Status chỉ có thể là 'active', 'inactive' hoặc 'suspended'.")]
        public string Status { get; set; } = "active";

        //[Range(0, 1, ErrorMessage = "IsFeatured chỉ có thể là 0 hoặc 1.")]
        public int IsFeatured { get; set; } = 0;
    }

    public class UpdateCompanyDto
    {
        //[StringLength(100, ErrorMessage = "Tên công ty không được vượt quá 100 ký tự.")]
        public string? CompanyName { get; set; }

        //[StringLength(50, ErrorMessage = "Mã số thuế không được vượt quá 50 ký tự.")]
        public string? TaxCode { get; set; }

        //[StringLength(255, ErrorMessage = "Địa chỉ không được vượt quá 255 ký tự.")]
        public string? Address { get; set; }

        //[StringLength(255, ErrorMessage = "Mô tả không được vượt quá 255 ký tự.")]
        public string? Description { get; set; }

        //[StringLength(255, ErrorMessage = "LogoCompany không được vượt quá 255 ký tự.")]
        public string? LogoCompany { get; set; }

        //[StringLength(255, ErrorMessage = "WebsiteUrl không được vượt quá 255 ký tự.")]
        //[Url(ErrorMessage = "WebsiteUrl phải là một URL hợp lệ.")]
        public string? WebsiteUrl { get; set; }

        //[StringLength(100, ErrorMessage = "Quy mô công ty không được vượt quá 100 ký tự.")]
        public string? Scale { get; set; }

        //[StringLength(100, ErrorMessage = "Ngành nghề không được vượt quá 100 ký tự.")]
        public string? Industry { get; set; }

        //[StringLength(255, ErrorMessage = "Link giấy phép kinh doanh không được vượt quá 255 ký tự.")]
        //[Url(ErrorMessage = "BusinessLicenseUrl phải là một URL hợp lệ.")]
        public string? BusinessLicenseUrl { get; set; }

        //[RegularExpression("^(active|inactive|suspended)$", ErrorMessage = "Status chỉ có thể là 'active', 'inactive' hoặc 'suspended'.")]
        public string? Status { get; set; }

        //[Range(0, 1, ErrorMessage = "IsFeatured chỉ có thể là 0 hoặc 1.")]
        public int? IsFeatured { get; set; }
    }

    public class CompanyDto
    {
        public string IdCompany { get; set; } = null!;

        public string CompanyName { get; set; } = null!;

        public string TaxCode { get; set; } = null!;

        public string? Address { get; set; } = null!;

        public string? Description { get; set; }

        public string? LogoCompany { get; set; }

        public string? WebsiteUrl { get; set; }

        public string Scale { get; set; } = null!;

        public string? Industry { get; set; } = null!;

        public string? BusinessLicenseUrl { get; set; }

        public string Status { get; set; } = null!;

        public int IsFeatured { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}
