using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("socialpost_hashtag")]
    public class SocialPostHashtag
    {
        [Key]
        [Column("idPost")]
        [StringLength(64)]
        public string IdPost { get; set; } = null!;

        [Key]
        [Column("idHashtag")]
        public long IdHashtag { get; set; }
    }
}


