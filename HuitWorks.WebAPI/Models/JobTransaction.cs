// File: Models/JobTransaction.cs
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("JobTransaction")]
    public class JobTransaction
    {
        [Key]
        [Column("idTransaction")]
        [StringLength(50)]
        public string IdTransaction { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(50)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("idPackage")]
        [StringLength(50)]
        public string IdPackage { get; set; } = null!;

        [Required]
        [Column("amount")]
        public decimal Amount { get; set; }

        [Column("paymentMethod")]
        [StringLength(50)]
        public string? PaymentMethod { get; set; }

        [Required]
        [Column("transactionDate")]
        public DateTime TransactionDate { get; set; }

        [Column("status")]
        [StringLength(20)]
        public string? Status { get; set; }    // "Completed", "Pending", ...

        [Required]
        [Column("startDate")]
        public DateTime StartDate { get; set; }

        [Required]
        [Column("expiryDate")]
        public DateTime ExpiryDate { get; set; }

        [Required]
        [Column("remainingJobPosts")]
        public int RemainingJobPosts { get; set; }

        [Required]
        [Column("remainingCvViews")]
        public int RemainingCvViews { get; set; }

        // Navigation
        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }

        [ForeignKey(nameof(IdPackage))]
        public SubscriptionPackage? SubscriptionPackage { get; set; }
    }
}
