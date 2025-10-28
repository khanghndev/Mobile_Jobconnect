using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("companyReview")]
    public class CompanyReview
    {
        [Key]
        [Column("idReview")]
        [StringLength(64)]
        public string IdReview { get; set; } = null!;

        [Required]
        [Column("idCompany")]
        [StringLength(64)]
        public string IdCompany { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("rating")]
        public int Rating { get; set; }

        [Column("comment", TypeName = "TEXT")]
        public string? Comment { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdCompany))]
        public Company? Company { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}


