using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("saveCandidate")]
    public class SaveCandidate
    {
        [Key, Column(Order = 0)]
        [StringLength(64)]
        public required string IdUserRecruiter { get; set; }

        [Key, Column(Order = 1)]
        [StringLength(64)]
        public required string IdUserCandidate { get; set; }

        [Column("savedAt")]
        public DateTime SavedAt { get; set; } = DateTime.Now;

        public string? Note { get; set; }
    }
}
