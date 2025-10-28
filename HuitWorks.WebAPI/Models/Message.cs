using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("messages")]
    public class Message
    {
        [Key]
        [Column("idMessage")]
        [StringLength(64)]
        public string IdMessage { get; set; } = null!;

        [Required]
        [Column("idConversation")]
        [StringLength(64)]
        public string IdConversation { get; set; } = null!;

        [Required]
        [Column("idSender")]
        [StringLength(64)]
        public string IdSender { get; set; } = null!;

        [Column("content", TypeName = "TEXT")]
        public string? Content { get; set; }

        [Column("messageType", TypeName = "enum('text','image','file','video')")]
        public string MessageType { get; set; } = "text";

        [Column("fileUrl", TypeName = "TEXT")]
        public string? FileUrl { get; set; }

        [Column("fileName")]
        public string? FileName { get; set; }

        [Column("fileSize")]
        public long? FileSize { get; set; }

        [Column("sentAt")]
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        [Column("isRead")]
        public int IsRead { get; set; } = 0;

        [ForeignKey(nameof(IdConversation))]
        public Conversation? Conversation { get; set; }

        [ForeignKey(nameof(IdSender))]
        public User? Sender { get; set; }
    }
}


