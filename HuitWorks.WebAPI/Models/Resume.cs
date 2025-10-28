using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HuitWorks.WebAPI.Models
{
    [Table("resumes")]
    public class Resume
    {
        [Key]
        [Column("idResume")]
        public required string IdResume { get; set; }

        [Required]
        [Column("idUser")]
        public required string IdUser { get; set; }

        [Required]
        [Column("fileUrl")]
        public required string FileUrl { get; set; }

        [Required]
        [Column("fileName")]
        public required string FileName { get; set; }

        [Column("fileId")]
        public string? FileId { get; set; }

        [Column("fileSizeKB")]
        public int FileSizeKB { get; set; }

        [Required]
        [Column("isDefault")]
        public required int IsDefault { get; set; }

        [Required]
        [Column("createdAt")]
        public required DateTime CreatedAt { get; set; }

        [Required]
        [Column("updatedAt")]
        public required DateTime UpdatedAt { get; set; }
    }
}