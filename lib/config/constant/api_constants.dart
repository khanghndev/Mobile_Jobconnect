import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['API_URL'] ?? "";

  // AUTHENTICATION - Đăng nhập/Đăng ký
  static const String registerEndpoint = "/api/Auth/register";
  static const String loginEndpoint = "/api/Auth/login";
  static const String logoutEndpoint = "/api/Auth/logout";
  static const String socialLoginEndpoint = "/api/Auth/social-login";
  static const String getUserByIdEndpoint = "/api/Auth/{id}";
  static const String enterOtp = "/api/Auth/enter-otp";
  static const String forgotPassword = "/api/Auth/forgot-password";
  static const String verifyOtp = "/api/Auth/verify-otp";
  static const String verifyOtpReset = "/api/Auth/verify-otp-reset";
  static const String resetPassword = "/api/Auth/reset-password";
  static const String resendOtp = "/api/Auth/resend-otp";

  // USER & ROLE - Người dùng & Vai trò
  static const String userEndpoint = "/api/User";
  static const String roleEndpoint = "/api/Roles";
  static const String userByIdEndpoint = "/api/User/{id}";
  static const String userRoleEndpoint = "/api/User/{id}/role";

  // RECRUITER & CANDIDATE - Nhà tuyển dụng & Ứng viên
  static const String recruiterInfoEndpoint = "/api/RecruiterInfo";
  static const String candidateInfoEndpoint = "/api/CandidateInfo";
  static const String candidateAvailabilityEndpoint = "/api/CandidateAvailability";
  static const String candidateAvailabilityByUserEndpoint = "/api/CandidateAvailability/user/{idUser}";
  static const String candidateAvailabilityByIdEndpoint = "/api/CandidateAvailability/{id}";
  static const String candidateEvaluationEndpoint = "/api/CandidateEvaluation";
  static const String candidateEvaluationByIdEndpoint = "/api/CandidateEvaluation/{id}";
  static const String candidateProjectsEndpoint = "/api/CandidateProjects";
  static const String candidateProjectsByUserEndpoint = "/api/CandidateProjects/user/{idUser}";
  static const String candidateProjectsByIdEndpoint = "/api/CandidateProjects/{id}";
  static const String candidateSkillsEndpoint = "/api/CandidateSkills";
  static const String candidateSkillsByUserEndpoint = "/api/CandidateSkills/user/{idUser}";
  static const String candidateSkillsByIdEndpoint = "/api/CandidateSkills/{id}";
  static const String saveCandidateEndpoint = "/api/SaveCandidate";

  // JOB POSTING - Tin tuyển dụng
  static const String jobPostingEndpoint = "/api/JobPosting";
  static const String jobPostingAllEndpoint = "/api/JobPosting/all";
  static const String jobPostingFeaturedEndpoint = "/api/JobPosting/featured";
  static const String jobPostingByCompanyEndpoint = "/api/JobPosting/company/{companyId}";
  static const String jobPostingSearchEndpoint = "/api/JobPosting/search";
  static const String jobPostingNearbyEndpoint = "/api/JobPosting/nearby";
  static const String jobPostingAreaEndpoint = "/api/JobPosting/area";
  static const String jobPostingByIdEndpoint = "/api/JobPosting/{id}";
  static const String jobPostingStatusEndpoint = "/api/JobPosting/{id}/status";

  // JOB APPLICATION - Ứng tuyển việc làm
  static const String jobApplicationEndpoint = "/api/JobApplication";
  static const String jobApplicationByUserEndpoint = "/api/JobApplication/user/{idUser}";
  static const String jobApplicationByJobPostEndpoint = "/api/JobApplication/jobposting/{jobPost}";
  static const String jobApplicationByIdEndpoint = "/api/JobApplication/{jobPost}/{user}";

  // SAVED JOBS - Việc làm đã lưu
  static const String jobSavedEndpoint = "/api/JobSaved";
  static const String jobSavedByJobPost = "/api/JobSaved/jobposting/{jobPost}";
  static const String jobSavedByUser = "/api/JobSaved/user/{idUser}";
  static const String jobSavedCheck = "/api/JobSaved/{jobPost}/{user}";
  static const String jobSavedDelete = "/api/JobSaved/{jobPost}/{user}";

  // JOBRECOMMENDATION - Gợi ý công vụ
  static const String jobRecommendationEndpoint = "/api/JobRecommendation";
  static const String jobRecommendationPersonalized = "$jobRecommendationEndpoint/personalized";
  static const String jobRecommendationHomepage = "$jobRecommendationEndpoint/homepage";
  static const String jobRecommendationTrendingSkills = "$jobRecommendationEndpoint/trending-skills";
  static const String jobRecommendationPopularLocations = "$jobRecommendationEndpoint/popular-locations";
  static const String jobRecommendationMatchScore = "$jobRecommendationEndpoint/match-score/{jobId}";
  static const String jobRecommendationHomepagePublic = "$jobRecommendationEndpoint/homepage/public";
  static const String jobRecommendationSmartSchedule = "$jobRecommendationEndpoint/smart-schedule";

  // JOBCATEGORY - Danh sách danh mục
  static const String jobCategory = "/api/JobCategory";
  static const String jobCategoryAll = "/api/JobCategory/all";
  static const String jobCategoryById = "/api/JobCategory/{id}";
  static const String jobCategoryByCode = "/api/JobCategory/code/{code}";


  // RESUME - Hồ sơ & Kỹ năng
  static const String resumeEndpoint = "/api/Resume";
  static const String resumeSkillEndpoint = "/api/ResumeSkill";
  static const String savedResumeEndpoint = "/api/SavedResume";
  static const String setDefaultResumeEndpoint = "/api/Resume/set-default";

  // COMPANIES - Doanh nghiệp
  static const String companiesEndpoint = "/api/Companies";
  static const String companiesFeaturedEndpoint = "/api/Companies/featured";
  static const String companyByIdEndpoint = "/api/Companies/{id}";
  static const String companyReviewsEndpoint = "/api/CompanyReviews";
  static const String companyReviewsByCompanyEndpoint = "/api/CompanyReviews/by-company/{companyId}";
  static const String companyReviewByIdEndpoint = "/api/CompanyReviews/{id}";

  // PODCAST - Podcast nghề nghiệp
  static const String podcastEndpoint = "/api/Podcast";
  static const String podcastFeaturedEndpoint = "/api/Podcast/featured";
  static const String podcastByIdEndpoint = "/api/Podcast/{id}";

  // CHAT & NOTIFICATIONS - Trò chuyện & Thông báo
  static const String conversationsEndpoint = "/api/Conversations";
  static const String conversationsByUserEndpoint = "/api/Conversations/by-user/{userId}";
  static const String conversationMessagesEndpoint = "/api/Conversations/{conversationId}/messages";
  static const String conversationMembersEndpoint = "/api/Conversations/{conversationId}/members";
  static const String conversationMemberByIdEndpoint = "/api/Conversations/{conversationId}/members/{userId}";
  static const String notificationEndpoint = "/api/Notification";
  static const String notificationByIdEndpoint = "/api/Notification/{id}";
  static const String notificationByIdUserEndpoint = "/api/Notification/user/{idUser}";
  static const String notificationMarkReadEndpoint = "/api/Notification/mark-read";

  static const String socialMessageEndpoint = "/api/SocialMessages";
  static const String socialMessageByIdEndpoint = "/api/SocialMessages/{id}";
  static const String socialMessageMarkReadEndpoint = "/api/SocialMessages/mark-read";
  static const String socialMessageUnreadCountEndpoint = "/api/SocialMessages/unread-count";

  // CHAT - Trò chuyện
  static const String createConversationEndpoint = "/api/Conversations";
  static const String addMemberToConversationEndpoint = "/api/Conversations/{conversationId}/members";
  static const String removeMemberFromConversationEndpoint = "/api/Conversations/{conversationId}/members/{userId}";
  static const String getConversationsByUserEndpoint = "/api/Conversations/by-user/{userId}";
  static const String getConversationMessagesEndpoint = "/api/Conversations/{conversationId}/messages";

  // MESSAGES - Tin nhắn
  static const String createMessageEndpoint = "/api/Messages";
  static const String sendMessageEndpoint = "/api/Messages/send";
  static const String getMessagesByConversationIdEndpoint = "/api/Messages/by-conversation/{conversationId}";
  static const String markMessagesAsReadEndpoint = "/api/Messages/mark-read/{conversationId}";
  static const String getUnreadMessageCountEndpoint = "/api/Messages/unread-count/{userId}";

  // CHAT - Trò chuyện
  static const String chatEndpoint = "/api/Chat"; 
  static const String chatThreadsEndpoint = "/api/chat/threads";
  static const String chatMessagesEndpoint = "/api/chat/threads";

  // INTERVIEW SCHEDULE - Lịch phỏng vấn
  static const String interviewScheduleEndpoint = "/api/InterviewSchedule";
  static const String interviewScheduleByIdEndpoint = "/api/InterviewSchedule/{id}";

  // NEWS - Tin tức
  static const String newsEndpoint = "/api/News";
  static const String newsByIdEndpoint = "/api/News/{id}";

  // SUBSCRIPTION - Gói dịch vụ
  static const String subscriptionPackageEndpoint = "/api/SubscriptionPackage"; 
  static const String subscriptionPackageByIdEndpoint = "/api/SubscriptionPackage/{id}";
  static const String jobTransactionEndpoint = "/api/JobTransaction";
  static const String jobTransactionByIdEndpoint = "/api/JobTransaction/{id}";
  static const String jobTransactionDetailEndpoint = "/api/JobTransaction/detail/{idTransaction}";

  // SOCIAL - Bài viết, comment, like, kết nối, story, tag, messgae
  static const String socialPostsEndpoint = "/api/SocialPosts";
  static const String socialPostByIdEndpoint = "/api/SocialPosts/{id}";
  static const String socialPostLikeEndpoint = "/api/SocialPosts/{id}/like";
  static const String socialPostLikesEndpoint = "/api/SocialPosts/{id}/likes";
  static const String socialPostsFeedByUserEndpoint = "/api/SocialPosts/feed/{userId}";
  static const String socialPostsInGroupByUserEndpoint = "/api/Social/group/{groupId}";

  static const String socialMessagesSendEndpoint = "/api/SocialMessages/send";
  static const String socialMessagesThreadEndpoint = "/api/SocialMessages/thread";
  static const String socialMessagesMarkReadEndpoint = "/api/SocialMessages/mark-read";
  static const String socialMessagesUnreadCountEndpoint = "/api/SocialMessages/unread-count/{userId}";

  static const String socialCommentEndpoint = "/api/SocialComments";
  static const String socialCommentByIdEndpoint = "/api/SocialComments/{id}";
  static const String socialCommentsByPostEndpoint = "/api/SocialComments/by-post/{postId}";
  static const String socialCommentsRepliesEndpoint = "/api/SocialComments/replies/{parentId}";

  static const String socialConnectionsRequestEndpoint = "/api/SocialConnections/request";
  static const String socialConnectionsAcceptEndpoint = "/api/SocialConnections/accept";
  static const String socialConnectionsRejectEndpoint = "/api/SocialConnections/reject";
  static const String socialConnectionsCancelEndpoint = "/api/SocialConnections/cancel";
  static const String socialConnectionsBlockEndpoint = "/api/SocialConnections/block";
  static const String socialConnectionsUnfriendEndpoint = "/api/SocialConnections/unfriend";
  static const String socialConnectionsRequestsByUserEndpoint = "/api/SocialConnections/requests/{userId}";
  static const String socialConnectionsSentByUserEndpoint = "/api/SocialConnections/sent/{userId}";
  static const String socialConnectionsFriendsByUserEndpoint = "/api/SocialConnections/friends/{userId}";
  static const String socialConnectionsAcceptAllEndpoint = "/api/SocialConnections/accept-all";
  static const String socialConnectionsCancelAllEndpoint = "/api/SocialConnections/cancel-all";
  static const String socialConnectionsStatusEndpoint = "/api/SocialConnections/status";

  static const String socialGroupsEndpoint = "/api/SocialGroups";
  static const String socialGroupByIdEndpoint = "/api/SocialGroups/{id}";
  static const String socialGroupsJoinedEndpoint = "/api/SocialGroups/joined";
  static const String socialGroupsPendingEndpoint = "/api/SocialGroups/pending";
  static const String socialGroupsSearchEndpoint = "/api/SocialGroups/search";
  static const String socialGroupJoinEndpoint = "/api/SocialGroups/{id}/join";
  static const String socialGroupLeaveEndpoint = "/api/SocialGroups/{id}/leave";
  static const String socialGroupMembersEndpoint = "/api/SocialGroups/{id}/members";
  static const String socialGroupMembersRoleEndpoint = "/api/SocialGroups/{id}/members/role";
  static const String socialGroupMemberByIdEndpoint = "/api/SocialGroups/{id}/members/{userId}";
  static const String socialGroupsTagsEndpoint = "/api/SocialGroups/tags";
  static const String socialGroupsStatsEndpoint = "/api/SocialGroups/stats";

  // GROUP SOCIAL - Nhóm mạng xã hội
  static const String groupPostsEndpoint = "/api/GroupPosts";
  static const String groupPostByIdEndpoint = "/api/GroupPosts/{id}";
  static const String groupPostsByGroupEndpoint = "/api/GroupPosts/group/{groupId}";
  static const String groupPostReactionEndpoint = "/api/GroupPosts/{id}/reaction";
  static const String groupPostReactionsEndpoint = "/api/GroupPosts/{id}/reactions";
  static const String groupPostsPendingEndpoint = "/api/GroupPosts/pending/{groupId}";
  static const String groupPostApproveEndpoint = "/api/GroupPosts/approve";
  static const String groupPostStatsEndpoint = "/api/GroupPosts/stats/{groupId}";
  static const String groupPostNotificationsEndpoint = "/api/GroupPosts/notifications/{userId}";


  static const String groupCommentsEndpoint = "/api/GroupComments";
  static const String groupCommentByIdEndpoint = "/api/GroupComments/{id}";
  static const String groupCommentsByPostEndpoint = "/api/GroupComments/post/{postId}";
  static const String groupCommentRepliesEndpoint = "/api/GroupComments/{id}/replies";
  static const String groupCommentReactionEndpoint = "/api/GroupComments/{id}/reaction";
  static const String groupCommentReactionsEndpoint = "/api/GroupComments/{id}/reactions";

  static const String groupReactionsEndpoint = "/api/GroupReactions";
  static const String groupReactionByEntityEndpoint = "/api/GroupReactions/{entityType}/{entityId}";
  static const String groupReactionDeleteEndpoint = "/api/GroupReactions/{entityType}/{entityId}/{userId}";

  // SAVE POST - Lưu bài viết
  static const String savedPostsByUser = "/api/SavedPosts/user/{idUser}";
  static const String savedPostsFolders = "/api/SavedPosts/folders/{idUser}";
  static const String createSavedPost = "/api/SavedPosts";
  static const String updateSavedPost = "/api/SavedPosts";
  static const String deleteSavedPost = "/api/SavedPosts";

  // EVALUATION - Đánh giá ứng viên
  static const String evaluationCriteriaEndpoint = "/api/EvaluationCriteria";
  static const String evaluationCriteriaByIdEndpoint = "/api/EvaluationCriteria/{id}";
  static const String evaluationDetailEndpoint = "/api/EvaluationDetail";
  static const String evaluationDetailAllEndpoint = "/api/EvaluationDetail/all";
  static const String evaluationDetailByIdEndpoint = "/api/EvaluationDetail/{id}";

  // LOGGING - Nhật ký hoạt động
  static const String userActivityLogEndpoint = "/api/UserActivityLog";
  static const String jobPostUsageLogEndpoint = "/api/JobPostUsageLog";
  static const String cvViewUsageLogEndpoint = "/api/CvViewUsageLog";
  static const String cvViewUsageLogByIdEndpoint = "/api/CvViewUsageLog/{id}";

  // REPORT - Báo cáo
  static const String reportEndpoint = "/api/Report";
  static const String reportByIdEndpoint = "/api/Report/{id}";
  static const String reportTypeEndpoint = "/api/ReportType";
  static const String reportTypeByIdEndpoint = "/api/ReportType/{id}";

  // SUPPORT TICKETS - Vé hỗ trợ
  static const String supportTicketsEndpoint = "/api/SupportTickets";
  static const String supportTicketByIdEndpoint = "/api/SupportTickets/{id}";
  static const String supportTicketStatusEndpoint = "/api/SupportTickets/{id}/status";

  // JOB RECOMMENDATION - Gợi ý việc làm
  static const String jobRecommendationPersonalizedEndpoint = "/api/JobRecommendation/personalized";
  static const String jobRecommendationHomepageEndpoint = "/api/JobRecommendation/homepage";
  static const String jobRecommendationTrendingSkillsEndpoint = "/api/JobRecommendation/trending-skills";
  static const String jobRecommendationPopularLocationsEndpoint = "/api/JobRecommendation/popular-locations";
  static const String jobRecommendationMatchScoreEndpoint = "/api/JobRecommendation/match-score/{jobId}";

  // WEBSITES - Website
  static const String websiteEndpoint = "/api/Websites";
  static const String websiteByIdEndpoint = "/api/Websites/{id}";

}