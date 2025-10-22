import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';

class CardPromptToPage extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;

  const CardPromptToPage({
    super.key,
    this.onPressed,
    this.icon = Icons.login_rounded,
    this.title = "Bạn Chưa Đăng Nhập",
    this.subtitle =
        "Đăng nhập để quản lý tài khoản và trải nghiệm đầy đủ các tính năng của ${AppStrings.appName}.",
    this.buttonText = "Đăng Nhập Ngay",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.07),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48.sp,
            color: theme.primaryColor.withValues(alpha: 0.8),
          ),
          SizedBox(height: 16.sp),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.sp),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4.h,
            ),
          ),
          SizedBox(height: 20.h),
          CustomButtomLeadingIcon(
            onPressed: () => onPressed,
            text:  buttonText,
            icon: icon,
            iconColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.primaryColor,
            textColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
