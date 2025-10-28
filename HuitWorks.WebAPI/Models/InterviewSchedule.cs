using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("InterviewSchedule")]
    public class InterviewSchedule
    {
        [Key]
        [Column("idSchedule")]
        [StringLength(50)]
        public string IdSchedule { get; set; } = null!;

        [Required]
        [Column("idJobPost")]
        [StringLength(64)]
        public string IdJobPost { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("interviewDate")]
        public DateTime InterviewDate { get; set; }

        [Column("interviewMode")]
        [StringLength(50)]
        public string? InterviewMode { get; set; }

        [Column("location")]
        [StringLength(255)]
        public string? Location { get; set; }

        [Column("interviewer")]
        [StringLength(100)]
        public string? Interviewer { get; set; }

        [Column("note")]
        public string? Note { get; set; }

    }
}
