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
    final isCandidate = role == UserRole.candidate.name ;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            margin: EdgeInsets.only(top: 10.h),
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                AppImages.logoApp,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  FontAwesomeIcons.userTie,
                  size: 60.sp,
                  color: IconColors.iconBrandPrimary
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            isCandidate
              ? '${AppStrings.appName} Chào Bạn'
              : 'Nhà Tuyển Dụng ${AppStrings.appName}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Đăng nhập để tiếp tục tìm kiếm ${isCandidate ? 'công việc' : 'ứng viên'} với ${AppStrings.appName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 32.h),

          // Nút login app
          CustomButtomLeadingIcon(
            onPressed: onShowTraditionalLogin,
            text: 'Đăng nhập với ${AppStrings.appName}',
            backgroundColor: BackgroundColors.backgroundBrandPrimary,
            textColor: TextColors.textBrandOnbrand,
            icon: Icons.business_center,
            iconColor: IconColors.iconBrandOnbrand,
            hasBorder: false,
          ),
          SizedBox(height: 20.h),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'hoặc tiếp tục với',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const Expanded(child: Divider(thickness: 1)),
            ],
          ),
          SizedBox(height: 20.h),

          // Google login button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => onGoogleLogin(context),
              icon: Image.asset(
                AppImages.google,
                width: 24.w,
                height: 24.w,
              ),
              label: Text(
                'Đăng nhập bằng Google',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: TextColors.textDefaultPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey.withAlpha(77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.w,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),

          SizedBox(height: 48.h),
          if(isCandidate)...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản ${AppStrings.appName}?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}