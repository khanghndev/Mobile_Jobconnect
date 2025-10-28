using System;
using System.ComponentModel.DataAnnotations;

namespace HuitWorks.WebAPI.DTOs
{
    // DTO để trả về dữ liệu
    public class JobSavedDto
    {
        public string IdJobPost { get; set; } = null!;
        public string IdUser { get; set; } = null!;
    }

    // DTO để tạo mới (POST)
    public class CreateJobSavedDto
    {
        [Required(ErrorMessage = "ID tin tuyển dụng là bắt buộc.")]
        [StringLength(64)]
        public string IdJobPost { get; set; } = null!;

        [Required(ErrorMessage = "ID người dùng là bắt buộc.")]
        [StringLength(64)]
        public string IdUser { get; set; } = null!;
    }
}
