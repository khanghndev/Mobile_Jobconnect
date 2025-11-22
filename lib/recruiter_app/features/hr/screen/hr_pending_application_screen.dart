import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/model/role_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/recruiter_app/features/candidate/screens/detail_candidate_of_hr.dart';

class HrPendingApplicationScreen extends StatefulWidget {
  final List<JobApplicationModel> pendingApplications;

  const HrPendingApplicationScreen({
    super.key,
    required this.pendingApplications,
  });

  @override
  State<HrPendingApplicationScreen> createState() => _HrPendingApplicationScreenState();
}

class _HrPendingApplicationScreenState extends State<HrPendingApplicationScreen> {
  final UserService _accountService = UserService();
  final CandidateInfoService _candidateInfoService = CandidateInfoService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobPostingService _jobPostingService = JobPostingService();

  List<UserModel> accounts = [];
  List<CandidateInfoModel> candidates = [];
  List<JobPostingModel> jobs = [];
  bool isLoading = true;
  List<JobApplicationModel> localApplications = [];

  @override
  void initState() {
    super.initState();
    localApplications = List<JobApplicationModel>.from(widget.pendingApplications);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final List<UserModel> loadedAccounts = [];
      final List<CandidateInfoModel> loadedCandidates = [];
      final List<JobPostingModel> loadedJobs = [];

      for (var application in widget.pendingApplications) {
        final account = await _accountService.getUserById(id: application.idUser);
        loadedAccounts.add(account);

        final candidate = await _candidateInfoService.getCandidateById(id:application.idUser);
        loadedCandidates.add(candidate);

        final job = await _jobPostingService.getJobPostingById(jobId: application.idJobPost);
        loadedJobs.add(job!);
      }

      setState(() {
        accounts = loadedAccounts;
        candidates = loadedCandidates;
        jobs = loadedJobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> rejectApplication(JobApplicationModel application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối hồ sơ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối hồ sơ thành công.')),
      );

      setState(() {
        localApplications.removeWhere((app) =>
            app.idJobPost == application.idJobPost &&
            app.idUser == application.idUser);
        accounts.removeWhere((a) => a.idUser == application.idUser);
        candidates.removeWhere((c) => c.idUser == application.idUser);
        jobs.removeWhere((j) => j.idJobPost == application.idJobPost);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi từ chối hồ sơ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppbarTitleLarge(title: 'Hồ sơ đang chờ đánh giá'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: localApplications.length,
              padding: EdgeInsets.all(16.w),
              itemBuilder: (context, index) {
                final application = localApplications[index];

                final account = accounts.firstWhere(
                  (acc) => acc.idUser == application.idUser,
                  orElse: () => UserModel(
                    idUser: application.idUser,
                    userName: 'Ẩn danh',
                    email: '',
                    idRole: 'R02',
                    accountStatus: 'inactive',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    gender: 'Khác',
                    role: RoleModel(idRole: 'R02', roleName: 'Candidate'),
                  ),
                );

                final candidate = candidates.firstWhere(
                  (cand) => cand.idUser == application.idUser,
                  orElse: () => CandidateInfoModel(
                    idUser: application.idUser,
                    workPosition: 'Chưa cập nhật',
                  ),
                );

                final job = jobs.firstWhere(
                  (j) => j.idJobPost == application.idJobPost,
                  orElse: () => JobPostingModel(
                    idJobPost: application.idJobPost,
                    title: 'Không rõ vị trí',
                    salary: 0,
                    location: '',
                    workType: '',
                    experienceLevel: '',
                    idCompany: '',
                    description: '',
                    requirements: '',
                    applicationDeadline: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isFeatured: 0,
                    postStatus: 'draft',
                  ),
                );

                return Card(
                  elevation: 6,
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Avatar, tên ứng viên và icon xem CV
                        Stack(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30.r), // nửa size để tròn
                                  child: Image(
                                    image: ImageUtils.getImageProvider(account.avatarUrl),
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => ClipRRect(
                                      borderRadius: BorderRadius.circular(30.r),
                                      child: Image.asset(
                                        AppImages.defaultAvatar,
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.userName,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        candidate.workPosition ?? 'Chưa cập nhật vị trí',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 14.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 40.w), // khoảng trống cho icon xem CV
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                onPressed: () {
                                  // TODO: mở CV
                                  context.push('/resume/file', 
                                  extra: {
                                    'fileUrl': application.cvFileUrl, 
                                    'fileName': 'Hồ sơ ứng tuyển'
                                  });
                                },
                                icon: Icon(Icons.picture_as_pdf, color: Colors.red, size: 28.sp),
                                tooltip: 'Xem CV',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Thông tin chi tiết
                        Row(
                          children: [
                            Icon(Icons.school_outlined, color: Colors.blue, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                candidate.universityName ?? 'Chưa cập nhật trường đại học',
                                style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.star_outline, color: Colors.orange, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Điểm đánh giá: ${candidate.ratingScore?.toStringAsFixed(1) ?? 'Chưa có'}',
                              style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.work_outline, color: Colors.green, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Kinh nghiệm: ${candidate.experienceYears ?? 0} năm',
                              style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.location_history, color: Colors.green, size: 20.sp),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 260.w,
                              child: Text(
                                'Vị trí mong muốn: ${candidate.workPosition}',
                                style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Danh sách kỹ năng
                        Text(
                          'Kỹ năng:',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: (candidate.skills ?? 'Chưa cập nhật')
                              .split(',')
                              .map((skill) => InfoChip(
                                    label: skill.trim(),
                                    color: Colors.blue,
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 16.h),

                        // Thông báo ngày ứng tuyển kèm tên job
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.blue, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Ứng viên đã ứng tuyển vào ngày ${application.submittedAt.toLocal().toString().split(' ')[0]} cho vị trí ${job.title}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Nút hành động
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ButtonPrimaryGradient(
                                height: 62.h,
                                text: 'Chi tiết', 
                                onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CandidateDetailScreen(candidate: candidate, account: account),
                                  ),
                                );
                              },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(child: CustomButtonBorder(title: 'Từ chối', onPressed: () => rejectApplication(application),)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
