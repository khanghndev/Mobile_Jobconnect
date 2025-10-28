using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("recruiterInfo")]
    public class RecruiterInfo
    {
        [Key]
        [Column("idUser")]
        public required string IdUser { get; set; }

        [Column("title")]
        public required string? Title { get; set; }

        [Column("idCompany")]
        public string? IdCompany { get; set; }

        [Column("department")]
        public string? Department { get; set; }

        [Column("description")]
        public string? Description { get; set; }
    }
}
