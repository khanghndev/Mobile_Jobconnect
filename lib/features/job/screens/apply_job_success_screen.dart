import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_submit_button.dart';

class ApplyJobSuccessScreen extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String cvName;
  final String idUser;

  const ApplyJobSuccessScreen({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.cvName,
    required this.idUser,
  });

  void _onViewHistory(BuildContext context) {
    context.push('/job/history/', extra: {'idUser': idUser});
  }

  void _onGoHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(
        title: "Nộp Hồ Sơ Thành Công",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // Icon thành công
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80.sp,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 32.h),
              // Tiêu đề
              Text(
                "Nộp Hồ Sơ Thành Công!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Thông tin chi tiết
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.work_outline,
                      label: "Vị trí ứng tuyển",
                      value: jobTitle,
                    ),
                    SizedBox(height: 16.h),
                    _buildInfoRow(
                      context,
                      icon: Icons.business_outlined,
                      label: "Công ty",
                      value: companyName,
                    ),
                    SizedBox(height: 16.h),
                    _buildInfoRow(
                      context,
                      icon: Icons.description_outlined,
                      label: "CV đã sử dụng",
                      value: cvName,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Thông báo
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "Hồ sơ của bạn đã được gửi đến nhà tuyển dụng. Bạn có thể theo dõi trong 'Lịch sử ứng tuyển'.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              // Nút Xem lịch sử
              CustomSubmitButton(
                isLoading: false,
                onPressed: () => _onViewHistory(context),
                label: "XEM LỊCH SỬ",
                icon: Icons.history_rounded,
              ),
              SizedBox(height: 16.h),
              // Nút Quay về
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _onGoHome(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  icon: Icon(
                    Icons.home_outlined,
                    size: 22.sp,
                  ),
                  label: Text(
                    "VỀ TRANG CHỦ",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

