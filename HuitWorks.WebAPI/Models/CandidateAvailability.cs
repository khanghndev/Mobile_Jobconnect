using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("candidateAvailability")]
    public class CandidateAvailability
    {
        [Key]
        [Column("idAvailability")]
        [StringLength(64)]
        public string IdAvailability { get; set; } = string.Empty;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = string.Empty;

        [Column("availableDay")]
        [StringLength(20)]
        public string AvailableDay { get; set; } = string.Empty;

        [Required]
        [Column("startTime")]
        public TimeSpan StartTime { get; set; }

        [Required]
        [Column("endTime")]
        public TimeSpan EndTime { get; set; }

        // Navigation property
        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}
