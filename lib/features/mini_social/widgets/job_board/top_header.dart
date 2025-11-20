import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';

class TopHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  /// Màu icon back
  final Color? backIconColor;

  /// Màu icon settings
  final Color? settingsIconColor;

  /// Màu tiêu đề
  final Color? titleColor;

  /// Màu phụ đề
  final Color? subtitleColor;

  const TopHeader({
    super.key,
    this.onBack,
    this.onSettings,
    this.backIconColor,
    this.settingsIconColor,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Nút back
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: Icon(
                getAdaptiveBackIcon(context),
                size: 24.w,
                color: backIconColor ?? Colors.white,
              ),
            ),
            SizedBox(width: 8.w),

            // Logo
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.r),
                  child: Image.asset(
                    AppImages.logoApp,
                    fit: BoxFit.cover,
                    width: 100.w,
                    height: 100.h,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.business,
                        size: 70.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // Tiêu đề + phụ đề
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bảng tin ${AppStrings.appName}",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? Colors.white,
                  ),
                ),
                Text(
                  'Tìm việc làm nhanh chóng',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: subtitleColor ?? Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Icon Settings
        // IconButton(
        //   onPressed: onSettings,
        //   icon: Icon(
        //     Icons.settings_suggest_outlined,
        //     size: 24.w,
        //     color: settingsIconColor ?? Colors.white,
        //   ),
        // ),
      ],
    );
  }
}
