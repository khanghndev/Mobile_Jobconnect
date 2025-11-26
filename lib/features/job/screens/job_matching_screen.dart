import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/job/view_model/job_recommendation_view_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/profile/view_model/candidate_info_view_model.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:provider/provider.dart';

class JobMatchingScreen extends StatefulWidget {
  final String idUser;

  const JobMatchingScreen({super.key, required this.idUser});

  @override
  State<JobMatchingScreen> createState() => _JobMatchingScreenState();
}

class _JobMatchingScreenState extends State<JobMatchingScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jobRecommendationVM = context.read<JobRecommendationViewModel>();
    final userVM = context.read<UserViewModel>();
    final candidateVM = context.read<CandidateInfoViewModel>();

    // Load dữ liệu song song
    await Future.wait([
      jobRecommendationVM.loadPersonalizedJobs(limit: 20),
      userVM.getCurrentUser(widget.idUser),
      candidateVM.getCandidateDetail(widget.idUser),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobRecommendationVM = context.watch<JobRecommendationViewModel>();
    final userVM = context.watch<UserViewModel>();
    final candidateVM = context.watch<CandidateInfoViewModel>();

    return Scaffold(
      appBar: CustomAppbarTitleLarge(
        title: 'Gợi ý công việc',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: jobRecommendationVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Phần thông tin ứng viên
                  SliverToBoxAdapter(
                    child: _buildCandidateInfoSection(
                      theme,
                      userVM.currentUser,
                      candidateVM.candidateDetail,
                    ),
                  ),
                  
                  // Phần gợi ý công việc
                  if (jobRecommendationVM.personalizedJobs.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64.sp,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Chưa có gợi ý công việc',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Vui lòng cập nhật thông tin hồ sơ để nhận gợi ý phù hợp',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final job = jobRecommendationVM.personalizedJobs[index];
                            return _buildJobRecommendationCard(theme, job);
                          },
                          childCount: jobRecommendationVM.personalizedJobs.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// Widget hiển thị thông tin ứng viên
  Widget _buildCandidateInfoSection(
    ThemeData theme,
    UserModel? user,
    CandidateInfoModel? candidateInfo,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin ứng viên',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Dựa trên hồ sơ của bạn',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Thông tin chi tiết
          _buildInfoRow(
            theme,
            Icons.person,
            'Họ tên',
            user?.userName ?? 'Chưa cập nhật',
          ),
          SizedBox(height: 12.h),
          
          if (candidateInfo?.universityName != null && candidateInfo!.universityName!.isNotEmpty)
            _buildInfoRow(
              theme,
              Icons.school,
              'Trường/Chuyên ngành',
              candidateInfo.universityName!,
            )
          else if (candidateInfo?.educationLevel != null && candidateInfo!.educationLevel!.isNotEmpty)
            _buildInfoRow(
              theme,
              Icons.school,
              'Trình độ học vấn',
              candidateInfo.educationLevel!,
            ),
          
          if (candidateInfo?.universityName != null || candidateInfo?.educationLevel != null)
            SizedBox(height: 12.h),
          
          if (user?.dateOfBirth != null)
            _buildInfoRow(
              theme,
              Icons.calendar_today,
              'Ngày sinh',
              DateFormat('dd/MM/yyyy').format(user!.dateOfBirth!),
            ),
          
          if (user?.dateOfBirth != null) SizedBox(height: 12.h),
          
          if (candidateInfo?.skills != null && candidateInfo!.skills!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Kỹ năng',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: candidateInfo.skills!
                      .split(',')
                      .where((s) => s.trim().isNotEmpty)
                      .take(5)
                      .map((skill) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              skill.trim(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          
          if (candidateInfo?.experienceYears != null)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: _buildInfoRow(
                theme,
                Icons.work_history,
                'Kinh nghiệm',
                '${candidateInfo!.experienceYears} năm',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị card gợi ý công việc
  Widget _buildJobRecommendationCard(ThemeData theme, JobPostingModel job) {
    // API trả về matchScore dạng 0.0-1.0, cần nhân với 100 để chuyển thành phần trăm
    final matchScore = ((job.matchScore ?? 0.0) * 100).clamp(0.0, 100.0);
    final matchReason = job.matchReason ?? 'Không có thông tin phân tích';
    final matchedSkills = job.matchedSkills ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(
                idUser: widget.idUser,
                jobPosting: job,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với match score
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        if (job.company != null)
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 16.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  job.company!.companyName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Match score badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getMatchGradientColors(matchScore),
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getMatchColor(matchScore).withValues(alpha: 0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${matchScore.toStringAsFixed(0)}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          'Phù hợp',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Match score progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: matchScore / 100,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMatchColor(matchScore),
                  ),
                  minHeight: 8.h,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Phân tích vì sao phù hợp
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getMatchColor(matchScore).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _getMatchColor(matchScore).withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          size: 18.sp,
                          color: _getMatchColor(matchScore),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Phân tích phù hợp',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _getMatchColor(matchScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      matchReason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                    ),
                    if (matchedSkills.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: matchedSkills.take(5).map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getMatchColor(matchScore).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12.sp,
                                  color: _getMatchColor(matchScore),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  skill,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _getMatchColor(matchScore),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Thông tin công việc
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildInfoChip(
                    theme,
                    Icons.location_on_outlined,
                    FormatUtils.extractDistrictAndCity(job.location),
                  ),
                  _buildInfoChip(
                    theme,
                    Icons.work_outline,
                    job.workType,
                  ),
                  if (job.salary != null)
                    _buildInfoChip(
                      theme,
                      Icons.attach_money,
                      FormatUtils.formatSalary(job.salary!),
                    ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Button xem chi tiết
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(
                          idUser: widget.idUser,
                          jobPosting: job,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Xem chi tiết công việc'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  List<Color> _getMatchGradientColors(double score) {
    if (score >= 80) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (score >= 60) {
      return [Colors.orange.shade600, Colors.orange.shade400];
    } else {
      return [Colors.red.shade600, Colors.red.shade400];
    }
  }
}
