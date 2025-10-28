using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.Models
{
    [Table("SavedResume")]
    public class SavedResume
    {
        [Key]
        [Column("idSave")]
        [StringLength(50)]
        public required string IdSave { get; set; }

        [Required]
        [Column("idRecruiter")]
        [StringLength(50)]
        public required string IdRecruiter { get; set; }

        [Required]
        [Column("idCandidate")]
        [StringLength(50)]
        public required string IdCandidate { get; set; }

        [Required]
        [Column("savedAt")]
        public DateTime SavedAt { get; set; }
    }

}
