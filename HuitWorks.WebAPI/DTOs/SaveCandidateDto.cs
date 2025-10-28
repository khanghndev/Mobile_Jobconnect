using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class SaveCandidateDto
    {
        public string IdUserRecruiter { get; set; } = null!;
        public string IdUserCandidate { get; set; } = null!;
        public DateTime SavedAt { get; set; }
        public string? Note { get; set; }
    }

    public class CreateSaveCandidateDto
    {
        [Required(ErrorMessage = "IdUserRecruiter là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdUserRecruiter không được vượt quá 64 ký tự.")]
        public string IdUserRecruiter { get; set; } = null!;

        [Required(ErrorMessage = "IdUserCandidate là bắt buộc.")]
        [StringLength(64, ErrorMessage = "IdUserCandidate không được vượt quá 64 ký tự.")]
        public string IdUserCandidate { get; set; } = null!;

        public string? Note { get; set; }
    }

    public class UpdateSaveCandidateDto
    {
        public string? Note { get; set; }
    }
}
