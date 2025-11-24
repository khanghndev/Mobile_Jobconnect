import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/recruiter_app/features/hr/screen/hr_pending_application_screen.dart';

class WelcomeSectionWidget extends StatelessWidget {
  final String userName;
  final List<JobApplicationModel> pendingApplications;

  const WelcomeSectionWidget({
    super.key,
    required this.userName,
    required this.pendingApplications,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    const recruiterPrimary = Color(0xFF1A237E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER (Greeting + Date Button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    userName,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: recruiterPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "${now.day}/${now.month}/${now.year}",
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Subtitle
        Text(
          'Chúc bạn một ngày làm việc hiệu quả!',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.h),

        // PENDING APPLICATION CARD với gradient và shadow đẹp
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F0FE),
                Color(0xFFF0F7FF),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: recruiterPrimary.withValues(alpha: 0.1),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
                spreadRadius: 2.r,
              ),
            ],
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.1),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                // LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              Icons.pending_actions_rounded,
                              size: 20.sp,
                              color: recruiterPrimary,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Cần phê duyệt',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: recruiterPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${pendingApplications.length} hồ sơ ứng viên',
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 15.sp,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'đang chờ đánh giá',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF283593)],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: recruiterPrimary.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HrPendingApplicationScreen(
                                    pendingApplications: pendingApplications,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Xem ngay',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // RIGHT ICON
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 48.sp,
                    color: recruiterPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}