import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
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
                    'Xin chào,\n$userName',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.calendar_month,
                  size: 22.sp,
                ),
                label: Text(
                  "${now.day}/${now.month}/${now.year}",
                  style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                ),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // Subtitle
        Text(
          'Chúc bạn một ngày làm việc hiệu quả!',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 16.h),

        // PENDING APPLICATION CARD
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          color: const Color(0xFFE9F3FF),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cần phê duyệt',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${pendingApplications.length} hồ sơ ứng viên chờ đánh giá',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: ButtonPrimaryGradient(
                          text: 'Xem ngay', 
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HrPendingApplicationScreen(
                                  pendingApplications: pendingApplications,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // RIGHT ICON
                Icon(
                  Icons.article_outlined,
                  size: 60.sp,
                  color: const Color(0xFF3366FF).withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}