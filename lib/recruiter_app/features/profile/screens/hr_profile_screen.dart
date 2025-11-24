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
      
      // Lấy company với xử lý lỗi
      CompanyModel? comp;
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        try {
          comp = await companyService.getCompanyById(id: rec.idCompany!);
        } catch (e) {
          // Bỏ qua lỗi, để comp = null
          comp = null;
        }
      }
      
      List<JobPostingModel>? jobPostings;
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        try {
          jobPostings = await jobPostingService.getJobPostingsByCompany(companyId: rec.idCompany!);
        } catch (e) {
          jobPostings = [];
        }
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
    if (jobPostingsList == null || jobPostingsList!.isEmpty) return 0;
    final titles = jobPostingsList!.map((e) => e.title).where((title) => title.isNotEmpty).toSet();
    return titles.length;
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

    if (user == null || recruiterInfo == null) {
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
        color: const Color(0xFF1A237E),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header với gradient indigo
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A237E), // Indigo
                      Color(0xFF283593), // Indigo 800
                      Color(0xFF3949AB), // Indigo 700
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar bên trái
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 12.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 45.r,
                                backgroundColor: Colors.white,
                                backgroundImage: user?.avatarUrl?.isNotEmpty == true
                                    ? ImageUtils.getImageProvider(user!.avatarUrl!)
                                    : ImageUtils.getImageProvider(AppImages.defaultAvatar),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1A237E).withValues(alpha: 0.4),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.w),
                                child: InkWell(
                                  onTap: () {
                                    if (companyInfo != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HrEditProfileScreen(
                                            account: user!,
                                            company: companyInfo!,
                                            recruiterInfo: recruiterInfo!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.edit_rounded, color: Colors.white, size: 14.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        // Thông tin bên phải
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tên người dùng
                              Text(
                                user!.userName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              // Badge Nhà tuyển dụng
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.95),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 6.r,
                                      offset: Offset(0, 2.h),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.business_center_rounded,
                                      color: const Color(0xFF1A237E),
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "Nhà tuyển dụng",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1A237E),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              // Thông tin công ty
                              if (companyInfo != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.apartment_rounded,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        companyInfo!.companyName,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        companyInfo!.address,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (companyInfo!.industry.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.category_rounded,
                                        color: Colors.white.withValues(alpha: 0.85),
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          companyInfo!.industry,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ] else ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "Chưa có công ty",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13.sp,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, -4.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                child: ProfileStatsRow(
                  jobPostings: jobPostingsList?.length ?? 0,
                  jobApplications: jobApplicationsList.length,
                  positionsHired: getPosisionPost(),
                ),
              ),

              SizedBox(height: 10.h),

              // Contact Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                        blurRadius: 15.r,
                        offset: Offset(0, 6.h),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A237E).withValues(alpha: 0.1),
                                const Color(0xFF1A237E).withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1A237E), Color(0xFF283593)],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 3.h),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.contact_phone_rounded, color: Colors.white, size: 22.sp),
                              ),
                              SizedBox(width: 14.w),
                              Text(
                                "Thông tin liên hệ",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A237E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ProfileContactItem(icon: Icons.email_rounded, title: "Email", subtitle: user!.email, hasCopy: true),
                        ProfileContactItem(
                            icon: Icons.phone_rounded,
                            title: "Số điện thoại",
                            subtitle: user!.phoneNumber ?? "Chưa có số điện thoại",
                            hasCopy: true),
                        if (companyInfo != null)
                          ProfileContactItem(
                              icon: Icons.location_on_rounded,
                              title: "Địa điểm",
                              subtitle: companyInfo!.address,
                              isLast: true)
                        else
                          ProfileContactItem(
                              icon: Icons.location_on_rounded,
                              title: "Địa điểm",
                              subtitle: "Chưa có địa chỉ",
                              isLast: true),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Company Info
              if (companyInfo != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                          blurRadius: 15.r,
                          offset: Offset(0, 6.h),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1A237E).withValues(alpha: 0.1),
                                  const Color(0xFF1A237E).withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 3.h),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.apartment_rounded, color: Colors.white, size: 22.sp),
                                ),
                                SizedBox(width: 14.w),
                                Text(
                                  "Thông tin công ty",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A237E),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
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

              SizedBox(height: 16.h),

              // Recruitment Activity
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                        blurRadius: 15.r,
                        offset: Offset(0, 6.h),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A237E).withValues(alpha: 0.1),
                                const Color(0xFF1A237E).withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1A237E), Color(0xFF283593)],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 3.h),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.analytics_rounded, color: Colors.white, size: 22.sp),
                              ),
                              SizedBox(width: 14.w),
                              Text(
                                "Hoạt động tuyển dụng",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A237E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
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

              SizedBox(height: 16.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    ProfileActionButton(
                      text: "Chỉnh sửa hồ sơ",
                      icon: Icons.edit_rounded,
                      isPrimary: true,
                      onPressed: () {
                        if (companyInfo != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HrEditProfileScreen(
                                  account: user!, company: companyInfo!, recruiterInfo: recruiterInfo!),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 14.h),
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
                    SizedBox(height: 14.h),
                    ProfileActionButton(
                        text: "Đăng xuất",
                        icon: Icons.logout_rounded,
                        isDestructive: true,
                        onPressed: () => DialogUtils.showLogoutDialog(context)),
                    SizedBox(height: 24.h),
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
