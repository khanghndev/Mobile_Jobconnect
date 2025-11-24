import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class StatisticsSection extends StatelessWidget {
  final Color primaryColor;
  final List<List<JobApplicationModel>> jobApplicationsList;
  final List<JobPostingModel> jobPostingsList;

  final String trendCandidate;
  final String trendJob;
  final String trendInterview;

  final int Function(String status) getApplicationsWithStatus;

  const StatisticsSection({
    super.key,
    required this.primaryColor,
    required this.jobApplicationsList,
    required this.jobPostingsList,
    required this.trendCandidate,
    required this.trendJob,
    required this.trendInterview,
    required this.getApplicationsWithStatus,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const recruiterPrimary = Color(0xFF1A237E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 20.sp,
                    color: recruiterPrimary,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Thống kê tuyển dụng',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: recruiterPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem tất cả',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: recruiterPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: recruiterPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Grid thống kê
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.95,
          children: [
            _statisticCard(
              context,
              title: 'Ứng viên',
              count: jobApplicationsList.length.toString(),
              icon: Icons.people_outline,
              iconBg: const Color(0xFFE8F0FE),
              iconColor: recruiterPrimary,
              trendValue: '+$trendCandidate',
              trendUp: true,
            ),
            _statisticCard(
              context,
              title: 'Công việc đang tuyển',
              count: jobPostingsList.length.toString(),
              icon: Icons.work_outline,
              iconBg: const Color(0xFFFFF4E6),
              iconColor: const Color(0xFFFF8A47),
              trendValue: '+$trendJob',
              trendUp: true,
            ),
            _statisticCard(
              context,
              title: 'Đã phỏng vấn',
              count: getApplicationsWithStatus("interview").toString(),
              icon: Icons.record_voice_over_outlined,
              iconBg: const Color(0xFFE9F9E7),
              iconColor: const Color(0xFF4CAF50),
              trendValue: '+$trendInterview',
              trendUp: true,
            ),
            _statisticCard(
              context,
              title: 'Được tuyển',
              count: getApplicationsWithStatus("accepted").toString(),
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFF3F0FF),
              iconColor: const Color(0xFF7C4DFF),
              trendUp: null,
            ),
          ],
        ),
      ],
    );
  }

  // CARD ITEM
  Widget _statisticCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    String trendValue = '',
    required bool? trendUp,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON + TREND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.2),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 22.sp,
                    color: iconColor,
                  ),
                ),

                if (trendUp != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color:
                          trendUp ? const Color(0xFFE9F9E7) : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: trendUp
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                            : const Color(0xFFE53935).withValues(alpha: 0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp ? Icons.trending_up : Icons.trending_down,
                          size: 14.sp,
                          color: trendUp
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          trendValue,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: trendUp
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16.h),

            // BODY
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}