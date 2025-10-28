using Microsoft.AspNetCore.Rewrite;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("jobApplication")]
    public class JobApplication
    {
        [Key]
        [Required]
        [Column("idJobPost")]
        [StringLength(64)]
        public required string IdJobPost { get; set; }

        [Key]
        [Required]
        [Column("idUser")]
        public required string IdUser { get; set; }

        [Column("cvFileUrl")]
        public string? CvFileUrl { get; set; }

        [Column("coverLetter")]
        public string? CoverLetter { get; set; }

        [Required]
        [Column("applicationStatus")]
        public required string ApplicationStatus { get; set; }

        [Required]
        [Column("submittedAt")]
        public required DateTime SubmittedAt { get; set; }

        [Required]
        [Column("updatedAt")]
        public required DateTime UpdatedAt { get; set; }
        // Navigation property
        [ForeignKey(nameof(IdJobPost))]
        public JobPosting? JobPosting { get; set; }

    }
}