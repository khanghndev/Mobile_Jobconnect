namespace HuitWorks.WebAPI.Constants
{
    public static class Enums
    {
        // Trạng thái công ty
        public enum CompanyStatus
        {
            active,
            inactive,
            suspended
        }

        // Trạng thái tài khoản người dùng
        public enum AccountStatus
        {
            active,
            inactive,
            suspended
        }

        // Giới tính người dùng
        public enum Gender
        {
            male,
            female,
            other
        }

        // Hình thức làm việc
        public enum WorkType
        {
            fulltime,
            parttime,
            freelancer,
            remote,
            internship,
            fresher,
            senior,
            junior
        }

        // Trạng thái bài đăng
        public enum PostStatus
        {
            open,
            closed,
            draft
        }

        // Trạng thái đơn ứng tuyển
        public enum ApplicationStatus
        {
            pending,
            viewed,
            interview,
            accepted,
            rejected
        }
    }
}
