import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/features/auth/screens/register_screen.dart';

class SocialLoginView extends StatelessWidget {
  final String role;
  final VoidCallback onShowTraditionalLogin;
  final void Function(BuildContext) onGoogleLogin;

  const SocialLoginView({
    super.key,
    required this.onShowTraditionalLogin,
    required this.onGoogleLogin, 
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCandidate = role == UserRole.candidate.name;
    final isRecruiter = role == UserRole.recruiter.name;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isRecruiter ? 32.w : 28.w,
        vertical: isRecruiter ? 24.h : 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo với style chuyên nghiệp cho recruiter
          Container(
            width: isRecruiter ? 90.w : 100.w,
            height: isRecruiter ? 90.w : 100.w,
            decoration: isRecruiter
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                      width: 2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.15),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  )
                : const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                AppImages.logoApp,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  isRecruiter ? FontAwesomeIcons.briefcase : FontAwesomeIcons.userTie,
                  size: isRecruiter ? 45.sp : 50.sp,
                  color: isRecruiter
                      ? const Color(0xFF1A237E)
                      : IconColors.iconBrandPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: isRecruiter ? 20.h : 16.h),

          // Title với theme
          Text(
            isCandidate
              ? '${AppStrings.appName} Chào Bạn'
              : 'Nhà Tuyển Dụng ${AppStrings.appName}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: isRecruiter ? 22.sp : 20.sp,
              fontWeight: FontWeight.bold,
              color: isRecruiter
                  ? const Color(0xFF1A237E)
                  : theme.textTheme.headlineMedium?.color,
              letterSpacing: isRecruiter ? 0.5 : 0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          
          Text(
            isRecruiter
                ? 'Kết nối với những ứng viên tài năng và xây dựng đội ngũ xuất sắc'
                : 'Đăng nhập để tiếp tục tìm kiếm ${isCandidate ? 'công việc' : 'ứng viên'} với ${AppStrings.appName}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: isRecruiter
                  ? TextColors.textDefaultSecondary
                  : theme.textTheme.bodyMedium?.color,
              height: 1.4,
            ),
          ),
          SizedBox(height: isRecruiter ? 28.h : 24.h),

          // Nút login app với icon size phù hợp
          CustomButtomLeadingIcon(
            onPressed: onShowTraditionalLogin,
            text: isRecruiter
                ? 'Đăng nhập với Email'
                : 'Đăng nhập với ${AppStrings.appName}',
            backgroundColor: isRecruiter
                ? const Color(0xFF1A237E)
                : BackgroundColors.backgroundBrandPrimary,
            textColor: TextColors.textBrandOnbrand,
            icon: isRecruiter ? Icons.business_center_outlined : Icons.business_center,
            iconColor: IconColors.iconBrandOnbrand,
            hasBorder: false,
            iconSize: isRecruiter ? 22 : 20,
          ),
          SizedBox(height: 18.h),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: isRecruiter
                      ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'hoặc tiếp tục với',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: isRecruiter
                        ? TextColors.textDefaultSecondary
                        : TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: isRecruiter
                      ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Google login button với icon size 22.sp
          Center(
            child: ElevatedButton.icon(
              onPressed: () => onGoogleLogin(context),
              icon: Image.asset(
                AppImages.google,
                width: 20.w,
                height: 20.w,
              ),
              label: Text(
                'Đăng nhập bằng Google',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: TextColors.textDefaultPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                elevation: isRecruiter ? 2 : 4,
                shadowColor: isRecruiter
                    ? const Color(0xFF1A237E).withValues(alpha: 0.1)
                    : Colors.grey.withAlpha(77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isRecruiter ? 14.r : 12.r),
                  side: BorderSide(
                    color: isRecruiter
                        ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                        : Colors.grey.shade300,
                    width: isRecruiter ? 1.5.w : 1.w,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 13.h,
                  horizontal: 18.w,
                ),
              ),
            ),
          ),

          SizedBox(height: isRecruiter ? 28.h : 32.h),
          
          if(isCandidate)...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản ${AppStrings.appName}?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                        transitionsBuilder:(context, animation, secondaryAnimation, child) {
                          var curve = Curves.easeInOut;
                          var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: BackgroundColors.backgroundBrandPrimary,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Đăng ký',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textBrandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          SizedBox(height: 16.h),

          // Terms and Privacy
          Text(
            'Bằng cách tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: isRecruiter
                  ? TextColors.textDefaultTertiary
                  : TextColors.textDefaultPrimary.withValues(alpha: 0.5),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}