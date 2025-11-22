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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thống kê tuyển dụng',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem tất cả',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // Grid thống kê
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.0,
          children: [
            _statisticCard(
              context,
              title: 'Ứng viên',
              count: jobApplicationsList.length.toString(),
              icon: Icons.people_outline,
              iconBg: const Color(0xFFE2F1FF),
              iconColor: primaryColor,
              trendValue: '+$trendCandidate',
              trendUp: true,
            ),
            _statisticCard(
              context,
              title: 'Công việc đang tuyển',
              count: jobPostingsList.length.toString(),
              icon: Icons.work_outline,
              iconBg: const Color(0xFFFFEEE3),
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
              iconBg: const Color(0xFFE8E4FF),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON + TREND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    size: 22.sp, // 🔥 chuẩn hóa icon: 20–22–24.sp
                    color: iconColor,
                  ),
                ),

                if (trendUp != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:
                          trendUp ? const Color(0xFFE9F9E7) : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14.sp,
                          color: trendUp
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          trendValue,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 12.sp,
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

            // BODY
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      count,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}