using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialMessage")]
    public class SocialMessage
    {
        [Key]
        [Column("idMessage")]
        [StringLength(64)]
        public string IdMessage { get; set; } = null!;

        [Required]
        [Column("senderId")]
        [StringLength(64)]
        public string SenderId { get; set; } = null!;

        [Required]
        [Column("receiverId")]
        [StringLength(64)]
        public string ReceiverId { get; set; } = null!;

        [Required]
        [Column("content", TypeName = "TEXT")]
        public string Content { get; set; } = null!;

        [Column("isRead")]
        public int IsRead { get; set; } = 0;

        [Column("sentAt")]
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(SenderId))]
        public User? Sender { get; set; }

        [ForeignKey(nameof(ReceiverId))]
        public User? Receiver { get; set; }
    }
}


