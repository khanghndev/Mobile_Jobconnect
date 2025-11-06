import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/status_helper.dart';

class StatusCard extends StatelessWidget {
  final String apiStatus;
  final DateTime submittedAt;

  const StatusCard({
    super.key,
    required this.apiStatus,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color statusBgColor = AppStatus.getBgColor(apiStatus);
    final Color statusTextColor = AppStatus.getTextColor(apiStatus);
    final IconData statusIcon = AppStatus.getIcon(apiStatus);

    return Card(
      elevation: 3,
      shadowColor: statusBgColor.withValues(alpha: 0.3),
      color: statusBgColor.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(statusIcon, color: statusTextColor, size: 30.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng thái: ${AppStatus.getDisplayText(apiStatus)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                      letterSpacing: 0.3,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Ngày ứng tuyển: ${FormatUtils.formattedDateTime(submittedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusTextColor.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
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