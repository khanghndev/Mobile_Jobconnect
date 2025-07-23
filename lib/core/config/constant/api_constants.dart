class ApiConstants {
  // 🌐 BASE URL
  // Dùng HTTP nếu chạy Flutter trên Android Emulator (localhost = 10.0.2.2)
  static const String baseUrl = "http://10.0.2.2:5281";

  // 🔐 AUTHENTICATION - Đăng nhập/Đăng ký
  static const String registerEndpoint = "/api/Auth/register";      // Đăng ký
  static const String loginEndpoint = "/api/Auth/login";            // Đăng nhập

  // 👤 USER & ROLE - Người dùng & Vai trò
  static const String userEndpoint = "/api/User";                   // Thông tin người dùng
  static const String roleEndpoint = "/api/Role";                   // Danh sách vai trò

  // 🧑‍💼 RECRUITER & CANDIDATE - Nhà tuyển dụng & Ứng viên
  static const String recruiterInfoEndpoint = "/api/RecruiterInfo";   // Thông tin nhà tuyển dụng
  static const String candidateInfoEndpoint = "/api/CandidateInfo";   // Thông tin ứng viên

  // 📄 JOB POSTING - Tin tuyển dụng
  static const String jobPostingEndpoint = "/api/JobPosting";                  // Danh sách tin tuyển dụng
  static const String jobPostingSearchEndpoint = "/api/JobPosting/search";    // Tìm kiếm tin tuyển dụng
  static const String jobPostingFeaturedEndpoint = "/api/JobPosting/featured";// Tin nổi bật

  // 📝 JOB APPLICATION - Ứng tuyển việc làm
  static const String jobApplicationPostEndpoint = "/api/JobApplication";             // Nộp đơn ứng tuyển
  static const String jobApplicationEndpoint = "/api/JobApplication/user";            // Lấy ứng tuyển theo user
  static const String jobApplicationJobPostEndpoint = "/api/JobApplication/jobposting"; // Lấy ứng tuyển theo bài đăng

  // 💾 SAVED JOBS - Việc làm đã lưu
  static const String jobSavedPostEndpoint = "/api/JobSaved";          // Lưu công việc
  static const String jobSavedEndpoint = "/api/JobSaved/user";         // Lấy danh sách đã lưu theo user
  static const String jobSaveJobPostdEndpoint = "/api/JobSaved";       // (Alias) Dùng chung endpoint

  // 📄 RESUME - Hồ sơ & Kỹ năng
  static const String resumeEndpoint = "/api/Resume";                  // Hồ sơ ứng viên
  static const String resumeSkillEndpoint = "/api/ResumeSkill";       // Kỹ năng trong hồ sơ
  static const String savedResumeEndpoint = "/api/SavedResume";       // Hồ sơ đã lưu (cho nhà tuyển dụng)

  // 🏢 COMPANIES - Doanh nghiệp
  static const String companiesEndpoint = "/api/Companies";              // Danh sách công ty
  static const String companiesFeaturedEndpoint = "/api/Companies/featured"; // Công ty nổi bật

  // 🎧 PODCAST - Podcast nghề nghiệp
  static const String podcastEndpoint = "/api/Podcast";              // Danh sách podcast
  static const String podcastFeaturedEndpoint = "/api/Podcast/featured"; // Podcast nổi bật

  // 💬 CHAT & 🔔 NOTIFICATIONS - Trò chuyện & Thông báo
  static const String chatEndpoint = "/api/Chat";                    // Trò chuyện ứng viên ↔ nhà tuyển dụng
  static const String notificationEndpoint = "/api/Notification";    // Thông báo hệ thống

  // 📅 INTERVIEW SCHEDULE - Lịch phỏng vấn
  static const String interviewScheduleEndpoint = "/api/InterviewSchedule"; // Quản lý lịch phỏng vấn

  // 📰 NEWS - Tin tức
  static const String newsEndpoint = "/api/News";                    // Tin tức hệ thống

  // 💼 SUBSCRIPTION - Gói dịch vụ
  static const String subcriptionPackaageEndpoint = "/api/SubcriptionPackage"; // Gói dịch vụ
}
