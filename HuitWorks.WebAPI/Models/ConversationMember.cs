using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("conversationMembers")]
    public class ConversationMember
    {
        [Key]
        [Column("idConversation")]
        [StringLength(64)]
        public string IdConversation { get; set; } = null!;

        [Key]
        [Column("idUser")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;

        [Column("joinedAt")]
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(IdConversation))]
        public Conversation? Conversation { get; set; }

        [ForeignKey(nameof(IdUser))]
        public User? User { get; set; }
    }
}


