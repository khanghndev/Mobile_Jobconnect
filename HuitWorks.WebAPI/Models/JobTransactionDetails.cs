using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("JobTransactionDetails")]
    public class JobTransactionDetail
    {
        [Key]
        [Column("idTransaction")]
        [StringLength(50)]
        public string IdTransaction { get; set; } = string.Empty;

        [Column("amountFormatted")]
        [StringLength(100)]
        public string? AmountFormatted { get; set; }

        [Column("amountInWords")]
        public string? AmountInWords { get; set; }

        [Column("senderName")]
        [StringLength(100)]
        public string? SenderName { get; set; }

        [Column("senderBank")]
        [StringLength(100)]
        public string? SenderBank { get; set; }

        [Column("receiverName")]
        [StringLength(100)]
        public string? ReceiverName { get; set; }

        [Column("receiverBank")]
        [StringLength(100)]
        public string? ReceiverBank { get; set; }

        [Column("content")]
        public string? Content { get; set; }

        [Column("fee")]
        [StringLength(50)]
        public string? Fee { get; set; }

        [ForeignKey("IdTransaction")]
        public JobTransaction? JobTransaction { get; set; }
    }
}
