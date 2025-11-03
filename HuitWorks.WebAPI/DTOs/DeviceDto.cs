namespace HuitWorks.WebAPI.DTOs
{
    public class UpdateDeviceDto
    {
        public string IdUser { get; set; }     // ID người dùng
        public string OldToken { get; set; }   // Token cũ (tùy chọn)
        public string NewToken { get; set; }   // Token mới (bắt buộc)
    }
}
