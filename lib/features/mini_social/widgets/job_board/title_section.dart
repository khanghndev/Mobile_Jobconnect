import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_adaptive_button.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/badges_info.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String decription;
  final VoidCallback onApply;
  final VoidCallback onDetail;
  final List<String> badges;

  const TitleSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.decription,
    required this.onApply,
    required this.onDetail,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Phần text
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
                color: Colors.black, // đổi màu đen
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 16.sp,
                color: Colors.black, // đổi màu đen
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        BadgesInfo(badges: badges),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Html(
            data: decription,
            style: {
              'body': Style(
                fontSize: FontSize(14.sp),
                color: Colors.black, // đổi màu đen
                textAlign: TextAlign.center,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Phần nút
        Row(
          children: [
            Expanded(
              child: CustomAdaptiveButton(
                onPressed: onDetail,
                text: "Chi Tiết",
                backgroundColor: Colors.white,
                textColor: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                borderWidth: 1.w,
                borderColor: theme.colorScheme.primary.withValues(alpha: 0.7),
                preffixWidget: Icon(
                  Icons.info_outline_rounded,
                  size: 20.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomAdaptiveButton(
                onPressed: onApply,
                text: "Ứng tuyển",
                backgroundColor: theme.colorScheme.primary,
                textColor: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                preffixWidget: Icon(
                  Icons.send_rounded,
                  size: 20.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
