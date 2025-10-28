// File: DTOs/JobTransactionDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class JobTransactionDto
    {
        public string IdTransaction { get; set; } = null!;
        public string IdUser { get; set; } = null!;
        public string IdPackage { get; set; } = null!;
        public decimal Amount { get; set; }
        public string? PaymentMethod { get; set; }
        public DateTime TransactionDate { get; set; }
        public string? Status { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public int RemainingJobPosts { get; set; }
        public int RemainingCvViews { get; set; }
    }

    public class CreateJobTransactionDto
    {
        [Required]
        public string IdUser { get; set; } = null!;

        [Required]
        public string IdPackage { get; set; } = null!;

        [Required]
        public decimal Amount { get; set; }

        public string? PaymentMethod { get; set; }

        [Required]
        public DateTime TransactionDate { get; set; }

        [StringLength(20)]
        public string? Status { get; set; }
    }

    public class UpdateJobTransactionDto
    {
        public string? PaymentMethod { get; set; }
        public string? Status { get; set; }
        public int? RemainingJobPosts { get; set; }
        public int? RemainingCvViews { get; set; }
    }
}
