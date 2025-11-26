import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/enum/job_application_status.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_create_calendar_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/interview/service/interview_schedule_service.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateCombined {
  final CandidateInfoModel candidate;
  final UserModel account;
  final JobApplicationModel jobApplication;

  CandidateCombined({
    required this.candidate,
    required this.account,
    required this.jobApplication,
  });
}

class HrCandidateManagementScreen extends StatefulWidget {
  final String recruiterId;

  const HrCandidateManagementScreen({
    super.key,
    required this.recruiterId,
  });

  @override
  State<HrCandidateManagementScreen> createState() =>
      _HrCandidateManagementScreenState();
}

class _HrCandidateManagementScreenState extends State<HrCandidateManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // Danh sách filter options (bao gồm "Tất cả")
  // ignore: unused_field
  final List<String> _filters = [
    'Tất cả', // All
    'pending',
    'viewed',
    'interview',
    'accepted',
    'rejected',
  ];
  String _selectedFilter = 'Tất cả';

  // Dữ liệu gốc và đã filter
  List<CandidateCombined> _candidates = [];
  List<JobPostingModel> _jobPostings = [];
  List<InterviewScheduleModel> _interviewSchedules = [];
  final InterviewScheduleService _interviewScheduleService = InterviewScheduleService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  bool _isLoading = true;
  // ignore: unused_field
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    _searchController.addListener(() {
      setState(() {}); // rebuild khi search thay đổi
    });
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final recruiterService = RecruiterService();
      final jobPostingService = JobPostingService();
      final jobApplicationService = JobApplicationService();
      final candidateService = CandidateInfoService();
      final accountService = UserService();

      // 1) Lấy thông tin recruiter để có companyId
      final recruiterInfo =
          await recruiterService.getRecruiterById(id: widget.recruiterId);
      if (recruiterInfo == null) {
        throw Exception('Không tìm thấy thông tin nhà tuyển dụng.');
      }
      
      final String? companyId = recruiterInfo.idCompany;
      if (companyId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      if (companyId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2) Lấy list job postings của company
      final List<JobPostingModel> jobPostings =
          await jobPostingService.getJobPostingsByCompany(companyId: companyId);
      
      // Lưu job postings vào state để dùng sau
      _jobPostings = jobPostings;

      // 2.5) Load tất cả interview schedules cho các job postings
      final List<Future<List<InterviewScheduleModel>>> interviewFutures = jobPostings
          .map((job) => _interviewScheduleService
              .getInterviewScheduleByJobId(jobId: job.idJobPost)
              .catchError((e) => <InterviewScheduleModel>[]))
          .toList();
      
      final List<List<InterviewScheduleModel>> interviewResults = await Future.wait(interviewFutures);
      _interviewSchedules = interviewResults.expand((list) => list).toList();

      if (jobPostings.isEmpty) {
        setState(() {
          _candidates = [];
          _isLoading = false;
        });
        return;
      }

      // 3) Load tất cả job applications song song
      final List<Future<List<JobApplicationModel>>> jobAppFutures = jobPostings
          .map((job) => jobApplicationService
              .getApplicationsByJobPost(jobPostId: job.idJobPost)
              .catchError((e) => <JobApplicationModel>[]))
          .toList();

      final List<List<JobApplicationModel>> jobAppsList = await Future.wait(jobAppFutures);
      
      // Flatten danh sách job applications
      final List<JobApplicationModel> allJobApps = [];
      for (final jobApps in jobAppsList) {
        allJobApps.addAll(jobApps);
      }

      if (allJobApps.isEmpty) {
        setState(() {
          _candidates = [];
          _isLoading = false;
        });
        return;
      }

      // 4) Load candidate và account song song cho tất cả job applications
      final List<Future<CandidateCombined?>> candidateFutures = allJobApps.map((jobApp) async {
        CandidateInfoModel? candidate;
        UserModel? account;
        
        try {
          // Load candidate và account song song với error handling
          final candidateFuture = () async {
            try {
              return await candidateService.getCandidateById(id: jobApp.idUser);
            } catch (e) {
              return null;
            }
          }();
          
          final accountFuture = () async {
            try {
              return await accountService.getUserById(id: jobApp.idUser);
            } catch (e) {
              return null;
            }
          }();
          
          final results = await Future.wait([
            candidateFuture,
            accountFuture,
          ]);

          candidate = results[0] as CandidateInfoModel?;
          account = results[1] as UserModel?;
        } catch (e) {
          // Ignore errors
        }

        if (candidate != null && account != null) {
          return CandidateCombined(
            candidate: candidate,
            account: account,
            jobApplication: jobApp,
          );
        }
        return null;
      }).toList();

      // 6) Chờ tất cả futures hoàn thành
      final List<CandidateCombined?> results = await Future.wait(candidateFutures);
      
      // 7) Lọc bỏ null values
      final List<CandidateCombined> enriched = results
          .whereType<CandidateCombined>()
          .toList();

      setState(() {
        _candidates = enriched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Chuẩn hóa ngày
  String formatDate(DateTime datetime) {
    return DateFormat('dd/MM/yyyy').format(datetime);
  }

  // Chuẩn hóa rating
  double roundToOneDecimal(double value) {
    return (value * 10).round() / 10;
  }

  /// Kết hợp search + filter theo applicationStatus
  List<CandidateCombined> get _filteredCandidates {
    final query = _searchController.text.trim().toLowerCase();

    // 1) Filter theo search (name, workPosition, skills)
    List<CandidateCombined> filtered = _candidates.where((item) {
      final name = item.account.userName.toLowerCase();
      final position = (item.candidate.workPosition ?? '').toLowerCase();
      final skillsStr = item.candidate.skills ?? '';
      final skills = skillsStr
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .toList();

      if (query.isEmpty) return true;
      if (name.contains(query) || position.contains(query)) return true;
      return skills.any((skill) => skill.contains(query));
    }).toList();

    // 2) Filter theo trạng thái ứng tuyển (applicationStatus)
    if (_selectedFilter != 'Tất cả') {
      final lowerFilter = _selectedFilter.toLowerCase();
      filtered = filtered.where((item) {
        final status = (item.jobApplication.applicationStatus).toLowerCase();
        return status == lowerFilter;
      }).toList();
    }

    return filtered;
  }

  // Chuẩn hóa từ accepted thành đã nhận việc

  String normalizeJobApplicationStatus(String status) {
    switch (status) {
      case 'viewed':
        return 'Đã xem';
      case 'interview':
        return 'Đang phỏng vấn';  
      case 'accepted':
        return 'Đã nhận việc';
      case 'rejected':
        return 'Đã từ chối';
      case 'pending':
        return 'Mới nộp hồ sơ';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu theo trạng thái
  Color _getStatusColor(String status) {
    const recruiterPrimary = Color(0xFF1A237E);
    switch (status) {
      case 'pending':
        return recruiterPrimary;
      case 'viewed':
        return Colors.grey;
      case 'interview':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  // Lấy icon theo trạng 
  Icon _getStatusIcon(String status) {
    const recruiterPrimary = Color(0xFF1A237E);
    switch (status) {
      case 'pending':
        return Icon(Icons.file_present, size: 20.sp, color: recruiterPrimary);
      case 'viewed':
        return Icon(Icons.pending_actions, size: 20.sp, color: Colors.grey);
      case 'interview':
        return Icon(Icons.check_circle_outline, size: 20.sp, color: Colors.orange);
      case 'accepted':
        return Icon(Icons.task_alt, size: 20.sp, color: Colors.green);
      case 'rejected':
        return Icon(Icons.cancel_outlined, size: 20.sp, color: Colors.red);
      default:
        return Icon(Icons.person, size: 20.sp, color: Colors.grey);
    }
  }
  // Kiểm tra xem ứng viên đã có lịch phỏng vấn chưa
  bool _hasInterviewSchedule(CandidateCombined item) {
    return _interviewSchedules.any((schedule) =>
        schedule.idJobPost == item.jobApplication.idJobPost &&
        schedule.idUser == item.jobApplication.idUser);
  }

  // Hàm cập nhật trạng thái khi bấm nút "Chấp nhận"
  Future<void> _acceptApplication(CandidateCombined item) async {
    // Lưu context của Scaffold cha và Navigator trước khi đóng bottom sheet
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      //   Implement update job application status API
      // await jobApplicationService.updateJobApplicationStatus(
      //   jobPostId: item.jobApplication.idJobPost,
      //   userId: item.jobApplication.idUser,
      //   newStatus: "interview",
      // );
      
      // Đóng bottom sheet trước
      navigator.pop();
      
      // Chờ một frame để đảm bảo bottom sheet đã đóng hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Kiểm tra mounted trước khi tiếp tục
      if (!mounted) return;
      
      // Tạo danh sách candidates (chỉ có candidate hiện tại)
      final candidateList = [item.account];
      
      // Navigate đến màn hình tạo lịch phỏng vấn với pre-selected job và candidate
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => HrCreateCalendarInterviewSchedule(
            jobs: _jobPostings,
            candidateList: candidateList,
            preSelectedJobId: item.jobApplication.idJobPost,
            preSelectedCandidateId: item.account.idUser,
          ),
        ),
      );
      
      // Sau khi quay lại từ màn hình tạo lịch, cập nhật trạng thái và reload
      if (mounted) {
        // Cập nhật trạng thái application thành "interview"
        try {
          final updatedApplication = item.jobApplication.copyWith(
            applicationStatus: 'interview',
          );
          await _jobApplicationService.updateApplication(
            jobPostId: item.jobApplication.idJobPost,
            userId: item.jobApplication.idUser,
            model: updatedApplication,
          );
        } catch (e) {
          debugPrint('Lỗi khi cập nhật trạng thái application: $e');
        }
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Đã chấp nhận ứng viên và tạo lịch phỏng vấn thành công.'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload data để cập nhật trạng thái và danh sách lịch phỏng vấn
        _loadCandidates();
      }
    } catch (e) {
      // Đóng bottom sheet nếu chưa đóng
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      // Chờ một frame
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Kiểm tra mounted trước khi hiển thị lỗi
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật trạng thái: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm cập nhật trạng thái khi bấm nút "Từ chối"
  Future<void> _rejectApplication(CandidateCombined item) async {
    // Lưu context của Scaffold cha trước khi đóng bottom sheet
    final scaffoldContext = context;
    
    try {
      //   Implement update job application status API
      // await jobApplicationService.updateJobApplicationStatus(
      //   jobPostId: item.jobApplication.idJobPost,
      //   userId: item.jobApplication.idUser,
      //   newStatus: "rejected",
      // );
      
      // Đóng bottom sheet trước
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Sau đó mới hiển thị SnackBar từ context của Scaffold cha
      if (mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật trạng thái thành công'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload data
        _loadCandidates();
      }
    } catch (e) {
      // Đóng bottom sheet trước
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Sau đó mới hiển thị SnackBar từ context của Scaffold cha
      if (mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật trạng thái: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mở ứng dụng email mặc định với địa chỉ đích.
  Future<void> _launchEmail(String email) async {
    // Tạo một URI dạng mailto: someone@example.com
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    // Kiểm tra có thể mở URI không
    if (!await canLaunchUrl(emailUri)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng email.')),
      );
      return;
    }

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// Mở ứng dụng gọi điện với số điện thoại
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (!await canLaunchUrl(phoneUri)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi điện.')),
      );
      return;
    }

    await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );
  }



  void _showCandidateDetails(CandidateCombined item) {
    final account = item.account;
    final skills = item.candidate.skills != null
        ? item.candidate.skills!.split(',').map((s) => s.trim()).toList()
        : <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết ứng viên',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: account.avatarUrl != null
                        ? ImageUtils.getImageProvider(account.avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 20),
                  // Tên + vị trí
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.candidate.workPosition ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: _getStatusColor(item.jobApplication.applicationStatus).withValues(alpha:0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                normalizeJobApplicationStatus(item.jobApplication.applicationStatus),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${roundToOneDecimal(item.candidate.ratingScore ?? 0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Contact information
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _contactInfoItem(Icons.email_outlined, account.email),
              _contactInfoItem(Icons.phone_outlined, account.phoneNumber ?? ''),
              const SizedBox(height: 10),

              const Text(
                'Thông tin chuyên môn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _infoItem('Vị trí ứng tuyển', item.candidate.workPosition ?? ''),
              _infoItem(
                'Kinh nghiệm',
                item.candidate.experienceYears != null
                    ? '${item.candidate.experienceYears} năm'
                    : '',
              ),
              _infoItem('Trường/Học',
                  item.candidate.universityName ?? ''),
              const SizedBox(height: 10),

              // Skills
              const Text(
                'Kỹ năng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: skills.map((skill) {
                  const recruiterPrimary = Color(0xFF1A237E);
                  const recruiterSecondary = Color(0xFF283593);
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          recruiterPrimary.withValues(alpha: 0.1),
                          recruiterSecondary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: recruiterPrimary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: recruiterPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),
              // Action buttons: chỉ hiển thị nếu trạng thái là 'pending' hoặc 'viewed'
              if (item.jobApplication.applicationStatus == 'pending' || item.jobApplication.applicationStatus == 'viewed')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _hasInterviewSchedule(item) ? null : () => _acceptApplication(item),
                        icon: Icon(
                          _hasInterviewSchedule(item) ? Icons.event_busy : Icons.check_circle_outline,
                          color: _hasInterviewSchedule(item) ? Colors.grey : Colors.white,
                        ),
                        label: Text(_hasInterviewSchedule(item) ? 'Đã có lịch' : 'Chấp nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasInterviewSchedule(item) ? Colors.grey.shade300 : Colors.green,
                          foregroundColor: _hasInterviewSchedule(item) ? Colors.grey : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectApplication(item),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                        label: const Text('Từ chối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for contact info
  Widget _contactInfoItem(IconData icon, String text) {
    const recruiterPrimary = Color(0xFF1A237E);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: recruiterPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: recruiterPrimary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
          IconButton(
            icon: Icon(Icons.content_copy, size: 18.sp),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã sao chép vào clipboard'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: recruiterPrimary,
                ),
              );
            },
            color: recruiterPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Helper for info row
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: recruiterPrimary, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Quản lý ứng viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: recruiterPrimary,
            fontSize: 18.sp,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: recruiterPrimary, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // 1) Card "Tất cả"
                  _buildStatsCard(
                    icon: Icons.person,
                    title: 'Tất cả',
                    value: _candidates.length.toString(),
                    color: _selectedFilter == 'Tất cả' ? recruiterPrimary : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Tất cả';
                      });
                    },
                  ),

                  // 2) Card "Mới nộp hồ sơ"
                  _buildStatsCard(
                    icon: Icons.file_present,
                    title: 'Mới nộp hồ sơ',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.pending.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.pending.name
                        ? recruiterPrimary
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.pending.name;
                      });
                    },
                  ),

                  // 3) Card "Đã xem"
                  _buildStatsCard(
                    icon: Icons.pending_actions,
                    title: 'Đã xem',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.viewed.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.viewed.name
                        ? Colors.orange
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.viewed.name;
                      });
                    },
                  ),

                  // 4) Card "Đang phỏng vấn"
                  _buildStatsCard(
                    icon: Icons.check_circle_outline,
                    title: 'Đang phỏng vấn',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.interview.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.interview.name
                        ? Colors.purple
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.interview.name;
                      });
                    },
                  ),

                  // 5) Card "Đã nhận việc"
                  _buildStatsCard(
                    icon: Icons.task_alt,
                    title: 'Đã nhận việc',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.accepted.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.accepted.name
                        ? Colors.green
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.accepted.name;
                      });
                    },
                  ),

                  // 6) Card "Đã từ chối"
                  _buildStatsCard(
                    icon: Icons.cancel_outlined,
                    title: 'Đã từ chối',
                    value: _candidates
                        .where((c) => 
                        c.jobApplication.applicationStatus == JobApplicationStatus.rejected.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.rejected.name
                        ? Colors.red
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.rejected.name;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm ứng viên...',
                      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: recruiterPrimary, size: 20.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                SizedBox(width: 10.w),
                // Hiển thị trạng thái filter hiện tại dưới dạng icon
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: _selectedFilter == 'Tất cả'
                        ? LinearGradient(
                            colors: [recruiterPrimary, recruiterSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _selectedFilter == 'Tất cả' ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: _selectedFilter == 'Tất cả'
                        ? [
                            BoxShadow(
                              color: recruiterPrimary.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: _selectedFilter == 'Tất cả'
                      ? Icon(Icons.list, size: 20.sp, color: Colors.white)
                      : _getStatusIcon(_selectedFilter),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Candidate List
          Expanded(
            child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(recruiterPrimary),
                  ),
                )
              : _filteredCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Không tìm thấy ứng viên',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredCandidates.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCandidates[index];
                        final account = item.account;
                        final skills = item.candidate.skills != null
                            ? item.candidate.skills!
                                .split(',')
                                .map((s) => s.trim())
                                .toList()
                            : <String>[];

                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          elevation: 2,
                          shadowColor: recruiterPrimary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _showCandidateDetails(item),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hàng đầu: Avatar + Tên + Rating + Trường/Học + Vị trí
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: recruiterPrimary.withValues(alpha: 0.2),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: recruiterPrimary.withValues(alpha: 0.1),
                                              blurRadius: 8.r,
                                              offset: Offset(0, 2.h),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 28.r,
                                          backgroundImage:
                                              account.avatarUrl != null
                                                  ? ImageUtils.getImageProvider(account.avatarUrl!)
                                                  : null,
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),

                                      // Expanded chứa Tên và Trường
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1) Tên
                                            Text(
                                              account.userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                                color: recruiterPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            // 2) Vị trí
                                            Text(
                                              item.candidate.workPosition ?? " ",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Cột phải: Rating 
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // 3) Rating
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 16
                                                ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${roundToOneDecimal(item.candidate.ratingScore ?? 0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                                                                          ],
                                          ),
                                          const SizedBox(height: 4),
                                          // // 4) Ngày ứng tuyển
                                          // Text(
                                          //   formatDate(item.jobApplication.submittedAt),
                                          //   maxLines: 1,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   style: TextStyle(
                                          //     color: Colors.grey[600],
                                          //     fontSize: 12,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Hàng 2: Skills 
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: skills.map((skill) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    recruiterPrimary.withValues(alpha: 0.1),
                                                    recruiterSecondary.withValues(alpha: 0.05),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                border: Border.all(
                                                  color: recruiterPrimary.withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                skill,
                                                style: TextStyle(
                                                  color: recruiterPrimary,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Hàng 3: Action buttons (email, phone) + status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item.jobApplication.applicationStatus).withValues(alpha:0.3),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          normalizeJobApplicationStatus(item.jobApplication.applicationStatus),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(width: 60),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.email_outlined),
                                            color: recruiterPrimary,
                                            iconSize: 20.sp,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final email = item.account.email;
                                              if (email.isNotEmpty) {
                                                _launchEmail(email);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Không có địa chỉ email để gửi.')),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.phone_outlined),
                                            color: Colors.green,
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final phone = item.account.phoneNumber;
                                              if (phone != null && phone.isNotEmpty) {
                                                _launchPhone(phone);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Không có số điện thoại để gọi.')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// Widget cho mỗi stats card. Nếu được chọn (isActive=true), border
  /// và màu icon/text sẽ đậm hơn.
  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
    final bool isActive = color != Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(16.w),
        width: 140.w,
        decoration: BoxDecoration(
          gradient: isActive && color == recruiterPrimary
              ? LinearGradient(
                  colors: [
                    recruiterPrimary.withValues(alpha: 0.15),
                    recruiterSecondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive && color != recruiterPrimary
              ? color.withValues(alpha: 0.2)
              : isActive
                  ? null
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? color
                : Colors.grey.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isActive ? color : Colors.grey, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isActive ? color : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive
                    ? color.withValues(alpha: 0.9)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
