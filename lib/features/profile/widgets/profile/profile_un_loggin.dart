import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';

class ProfileUnLoggin extends StatelessWidget {
  const ProfileUnLoggin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.9),
            theme.colorScheme.secondary.withValues(alpha: 0.7),
            theme.colorScheme.tertiary.withValues(alpha: 0.5),
          ],
          stops: const [0.1, 0.6, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.sentiment_very_dissatisfied_outlined,
                size: 100.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              SizedBox(height: 24.h),
              Text(
                "Bạn ơi, Đăng Nhập Nào!",
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.r,
                      color: Colors.black38,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Khám phá tiềm năng, kết nối cơ hội.\n"
                "Đăng nhập để bắt đầu hành trình sự nghiệp của bạn!",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: CustomPrimaryButton(
                  onPressed: (){
                    context.push("/auth/login");
                  }, 
                  text: "Đăng nhập",
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
