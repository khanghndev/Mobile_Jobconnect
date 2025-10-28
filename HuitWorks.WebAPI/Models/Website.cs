using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("websites")]
    public class Website
    {
        [Key]
        [Column("idWebsite")]
        [StringLength(64)]
        public required string IdWebsite { get; set; }

        [Required]
        [Column("name")]
        [StringLength(255)]
        public required string Name { get; set; }

        [Required]
        [Column("url")]
        [StringLength(2083)]
        public required string Url { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Required]
        [Column("isActive")]
        public required bool IsActive { get; set; }

        [Required]
        [Column("createdAt")]
        public required DateTime CreatedAt { get; set; }

        [Required]
        [Column("updatedAt")]
        public required DateTime UpdatedAt { get; set; }
    }
}
