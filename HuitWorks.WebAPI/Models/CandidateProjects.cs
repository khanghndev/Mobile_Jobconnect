using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("candidateProjects")]
    public class CandidateProjects
    {
        [Key]
        [Column("idProject")]
        [StringLength(64)]
        public string IdProject { get; set; } = string.Empty;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = string.Empty;

        [Required]
        [Column("projectName")]
        [StringLength(255)]
        public string ProjectName { get; set; } = string.Empty;

        [Column("projectUrl")]
        [StringLength(1000)]
        public string? ProjectUrl { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation property
        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}
