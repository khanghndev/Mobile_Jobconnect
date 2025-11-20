import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/recruiter_app/features/profile/widget/profile/profile_action_button.dart';
import 'package:job_connect/recruiter_app/features/profile/widget/profile/profile_analytics_card.dart';
import 'package:job_connect/recruiter_app/features/profile/widget/profile/profile_contact_item.dart';
import 'package:job_connect/recruiter_app/features/profile/widget/profile/profile_shimmer.dart';
import 'package:job_connect/recruiter_app/features/profile/widget/profile/profile_stats_row.dart';
import 'hr_edit_profile_screen.dart';
import 'package:job_connect/recruiter_app/features/candidate/screens/hr_candidate_management_screen.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RecruiterProfilePage extends StatefulWidget {
  final String recruiterId;
  const RecruiterProfilePage({super.key, required this.recruiterId, required UserModel account});

  @override
  State<RecruiterProfilePage> createState() => _RecruiterProfilePageState();
}

class _RecruiterProfilePageState extends State<RecruiterProfilePage> {
  final UserService accountService = UserService();
  final RecruiterService recruiterService = RecruiterService();
  final CompanyService companyService = CompanyService();
  final JobPostingService jobPostingService = JobPostingService();
  final JobApplicationService jobApplicationService = JobApplicationService();

  UserModel? user;
  RecruiterInfoModel? recruiterInfo;
  CompanyModel? companyInfo;

  List<JobPostingModel>? jobPostingsList;
  List<List<JobApplicationModel>> jobApplicationsList = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final rec = await recruiterService.getRecruiterById(id: widget.recruiterId);
      final acc = await accountService.getUserById(id: rec!.idUser);
      final comp = await companyService.getCompanyById(id: rec.idCompany!);
      List<JobPostingModel>? jobPostings;
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        jobPostings = await jobPostingService.getJobPostingsByCompany(companyId: rec.idCompany!);
      }

      setState(() {
        recruiterInfo = rec;
        user = acc;
        companyInfo = comp;
        jobPostingsList = jobPostings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  int getPosisionPost() {
    if (jobPostingsList == null) return 0;
    return jobPostingsList!.map((e) => e.title ?? '').toSet().length;
  }

  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép vào clipboard'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được link: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: ProfileShimmer()));
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: BackgroundErrorState(
            title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
            onRetry: _loadAllData,
          )
        )
      );
    }

    if (user == null || recruiterInfo == null || companyInfo == null) {
      return Scaffold(
        body: Center(
          child: BackgroundEmptyState(
            isSearching: true,
            onRefresh: _loadAllData,
            title: "Thông Tin Nhà Tuyển dụng",
            iconData: Icons.portrait,
          )
        )
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header
              Container(
                height: 260.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 45.r,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.avatarUrl?.isNotEmpty == true
                                ? ImageUtils.getImageProvider(user!.avatarUrl!)
                                : ImageUtils.getImageProvider(AppImages.defaultAvatar),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.w),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HrEditProfileScreen(
                                      account: user!,
                                      company: companyInfo!,
                                      recruiterInfo: recruiterInfo!,
                                    ),
                                  ),
                                ),
                                child: Icon(Icons.business_center, color: Colors.white, size: 14.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(user!.userName,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "Nhà tuyển dụng",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Công ty ${companyInfo!.companyName}",
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 14.sp),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Stats
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: EdgeInsets.all(20.w),
                child: ProfileStatsRow(
                  jobPostings: jobPostingsList?.length ?? 0,
                  jobApplications: jobApplicationsList.length,
                  positionsHired: getPosisionPost(),
                ),
              ),

              SizedBox(height: 10.h),

              // Contact Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child:
                                  Icon(Icons.contact_phone_rounded, color: theme.colorScheme.primary, size: 24.sp),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Thông tin liên hệ",
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1),
                        ProfileContactItem(icon: Icons.email_rounded, title: "Email", subtitle: user!.email, hasCopy: true),
                        ProfileContactItem(
                            icon: Icons.phone_rounded,
                            title: "Số điện thoại",
                            subtitle: user!.phoneNumber ?? "Chưa có số điện thoại",
                            hasCopy: true),
                        ProfileContactItem(
                            icon: Icons.location_on_rounded,
                            title: "Địa điểm",
                            subtitle: companyInfo!.address,
                            isLast: true),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Company Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r)),
                              child: Icon(Icons.apartment, color: theme.colorScheme.primary, size: 24.sp),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Thông tin công ty",
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1),
                        ProfileContactItem(icon: Icons.business_rounded, title: "Công ty", subtitle: companyInfo!.companyName),
                        ProfileContactItem(icon: Icons.people_rounded, title: "Quy mô", subtitle: companyInfo!.scale),
                        ProfileContactItem(
                            icon: Icons.public_rounded,
                            title: "Website",
                            subtitle: companyInfo!.websiteUrl ?? "Chưa có website",
                            hasLink: true,
                            isLast: true,
                            onOpenLink: () {
                              if (companyInfo?.websiteUrl != null) launchURL(companyInfo!.websiteUrl!);
                            }),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Recruitment Activity
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r)),
                              child: Icon(Icons.analytics_rounded, color: theme.colorScheme.primary, size: 24.sp),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Hoạt động tuyển dụng",
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                                child: ProfileAnalyticsCard(
                                    icon: Icons.description_rounded,
                                    title: "Tin tuyển dụng",
                                    value: jobPostingsList?.length.toString() ?? "0",
                                    color: Colors.blue)),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: ProfileAnalyticsCard(
                                    icon: Icons.people_alt_rounded,
                                    title: "Hồ sơ đã nhận",
                                    value: jobApplicationsList.length.toString(),
                                    color: Colors.green)),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                                child: ProfileAnalyticsCard(
                                    icon: Icons.check_circle_rounded,
                                    title: "Đã tuyển",
                                    value: getPosisionPost().toString(),
                                    color: Colors.orange)),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: ProfileAnalyticsCard(
                                    icon: Icons.remove_red_eye_rounded,
                                    title: "Lượt xem",
                                    value: "210",
                                    color: Colors.purple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    ProfileActionButton(
                      text: "Chỉnh sửa hồ sơ",
                      icon: Icons.add_circle_outline_rounded,
                      isPrimary: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HrEditProfileScreen(
                              account: user!, company: companyInfo!, recruiterInfo: recruiterInfo!),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ProfileActionButton(
                      text: "Quản lý hồ sơ ứng viên",
                      icon: Icons.people_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HrCandidateManagementScreen(recruiterId: widget.recruiterId),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ProfileActionButton(
                        text: "Đăng xuất",
                        icon: Icons.logout_rounded,
                        isDestructive: true,
                        onPressed: () => DialogUtils.showLogoutDialog(context)),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
