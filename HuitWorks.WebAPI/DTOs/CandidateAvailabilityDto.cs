using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    public class CandidateAvailabilityDto
    {
        public string IdAvailability { get; set; } = string.Empty;
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Ngày trong tuần là bắt buộc")]
        public string AvailableDay { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Thời gian bắt đầu là bắt buộc")]
        public TimeSpan StartTime { get; set; }
        
        [Required(ErrorMessage = "Thời gian kết thúc là bắt buộc")]
        public TimeSpan EndTime { get; set; }
    }

    public class CreateCandidateAvailabilityDto
    {
        [Required(ErrorMessage = "ID người dùng là bắt buộc")]
        public string IdUser { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Ngày trong tuần là bắt buộc")]
        public string AvailableDay { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Thời gian bắt đầu là bắt buộc")]
        public TimeSpan StartTime { get; set; }
        
        [Required(ErrorMessage = "Thời gian kết thúc là bắt buộc")]
        public TimeSpan EndTime { get; set; }
    }

    public class UpdateCandidateAvailabilityDto
    {
        [Required(ErrorMessage = "ID lịch rảnh là bắt buộc")]
        public string IdAvailability { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Ngày trong tuần là bắt buộc")]
        public string AvailableDay { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Thời gian bắt đầu là bắt buộc")]
        public TimeSpan StartTime { get; set; }
        
        [Required(ErrorMessage = "Thời gian kết thúc là bắt buộc")]
        public TimeSpan EndTime { get; set; }
    }
}
