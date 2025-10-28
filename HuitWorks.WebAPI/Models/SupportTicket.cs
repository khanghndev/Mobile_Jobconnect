using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("supportTicket")]
    public class SupportTicket
    {
        [Key]
        [Column("idTicket")]
        [StringLength(64)]
        public string IdTicket { get; set; } = null!;

        [Required]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Required]
        [Column("subject")]
        [StringLength(255)]
        public string Subject { get; set; } = null!;

        [Required]
        [Column("message", TypeName = "TEXT")]
        public string Message { get; set; } = null!;

        [Column("status", TypeName = "enum('open','in_progress','resolved','closed')")]
        [StringLength(20)]
        public string Status { get; set; } = "open";

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}


