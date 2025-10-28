using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("roles")]
    public class Role
    {
        [Key]
        [Column("idRole")]
        [StringLength(64)]
        public required string IdRole { get; set; }

        [Required]
        [Column("roleName")]
        [StringLength(100)]
        public required string RoleName { get; set; }

        [Column("description")]
        public string? Description { get; set; }
    }
}
