using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("conversations")]
    public class Conversation
    {
        [Key]
        [Column("idConversation")]
        [StringLength(64)]
        public string IdConversation { get; set; } = null!;

        [Column("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}


