using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("jobSaved")]
    public class JobSaved
    {
        [Key, Column(Order = 0)]
        [Required, StringLength(64)]
        public string IdJobPost { get; set; } = null!;

        [Key, Column(Order = 1)]
        [Required, StringLength(64)]
        public string IdUser { get; set; } = null!;
    }
}
