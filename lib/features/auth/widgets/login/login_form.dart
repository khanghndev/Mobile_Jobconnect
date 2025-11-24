import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_pass_field_with_label.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/features/auth/screens/forgot_password_screen.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onBack;
  final bool? isRemmeber;
  final String? role;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onBack,
    this.isRemmeber = true, 
    this.role
  });

  @override
  Widget build(BuildContext context) {
    final passwordVisible = ValueNotifier<bool>(false);
    final rememberMe = ValueNotifier<bool>(false);
    final theme = Theme.of(context);
    final isRecruiter = (role ?? UserRole.candidate.name)
        .toLowerCase() == UserRole.recruiter.name.toLowerCase();
    
    return Padding(
      padding: EdgeInsets.all(isRecruiter ? 28.w : 24.w),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo với style chuyên nghiệp cho recruiter
            Container(
              decoration: BoxDecoration(
                color: isRecruiter
                    ? const Color(0xFF1A237E).withValues(alpha: 0.1)
                    : BackgroundColors.backgroundDefaultPrimary,
                borderRadius: BorderRadius.circular(isRecruiter ? 24.r : 130.r),
                boxShadow: [
                  BoxShadow(
                    color: isRecruiter
                        ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                        : BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.1),
                    blurRadius: isRecruiter ? 16.r : 10.r,
                    offset: Offset(0, isRecruiter ? 6.h : 5.h),
                    spreadRadius: isRecruiter ? 2.r : 0,
                  ),
                ],
              ),
              padding: isRecruiter ? EdgeInsets.all(12.w) : EdgeInsets.zero,
              child: ClipOval(
                child: Image.asset(
                  AppImages.logoApp,
                  width: isRecruiter ? 85.w : 100.w,
                  height: isRecruiter ? 85.w : 100.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    isRecruiter ? FontAwesomeIcons.briefcase : FontAwesomeIcons.userTie,
                    size: isRecruiter ? 42.sp : 50.sp,
                    color: isRecruiter
                        ? const Color(0xFF1A237E)
                        : IconColors.iconBrandPrimary,
                  ),
                ),
              ),
            ),

            SizedBox(height: isRecruiter ? 18.h : 16.h),
            
            // Title với theme
            Text(
              isRecruiter ? 'Đăng nhập Nhà Tuyển Dụng' : 'Đăng nhập',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: isRecruiter ? 22.sp : 24.sp,
                fontWeight: FontWeight.bold,
                color: isRecruiter
                    ? const Color(0xFF1A237E)
                    : TextColors.textBrandPrimary,
                letterSpacing: isRecruiter ? 0.5 : 0,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (isRecruiter) ...[
              SizedBox(height: 6.h),
              Text(
                'Quản lý và tuyển dụng nhân tài hiệu quả',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  color: TextColors.textDefaultSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: isRecruiter ? 24.h : 20.h),

            // Email field
            CustomTextFieldWithLabel(
              controller: emailController,
              label: 'Email',
              hintText: isRecruiter ? 'Nhập email công ty' : 'Nhập email',
              fillColor: isRecruiter
                  ? const Color(0xFF1A237E).withValues(alpha: 0.05)
                  : theme.colorScheme.primary.withValues(alpha: 0.05),
              prefixIconColor: isRecruiter
                  ? const Color(0xFF1A237E)
                  : theme.colorScheme.primary,
              borderColor: isRecruiter
                  ? const Color(0xFF1A237E).withValues(alpha: 0.3)
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              icon: Icons.email_outlined,
              iconSize: 20.sp,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            ValueListenableBuilder<bool>(
              valueListenable: passwordVisible,
              builder: (context, visible, _) {
                return CustomPassFieldWithLabel(
                  controller: passwordController,
                  label: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  isObscure: !visible,
                  onToggleVisibility: () => passwordVisible.value = !visible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                  fillColor: isRecruiter
                      ? const Color(0xFF1A237E).withValues(alpha: 0.05)
                      : theme.colorScheme.primary.withValues(alpha: 0.05),
                  prefixIconColor: isRecruiter
                      ? const Color(0xFF1A237E)
                      : theme.colorScheme.primary,
                  suffixIconColor: isRecruiter
                      ? const Color(0xFF1A237E)
                      : theme.colorScheme.primary,
                  borderColor: isRecruiter
                      ? const Color(0xFF1A237E).withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: 14.r,
                  iconSize: 20.sp,
                );
              },
            ),

            SizedBox(height: 10.h),

            // Remember + Forgot password
            Row(
              children: [
                if(isRemmeber == true)...[
                  ValueListenableBuilder<bool>(
                    valueListenable: rememberMe,
                    builder: (_, checked, __) {
                      return Checkbox(
                        value: checked,
                        activeColor: isRecruiter
                            ? const Color(0xFF1A237E)
                            : const Color(0xFF1976D2),
                        onChanged: (value) => rememberMe.value = value ?? false,
                      );
                    },
                  ),
                  Text(
                    'Nhớ tài khoản',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 4.w),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isRecruiter
                            ? const Color(0xFF1A237E)
                            : TextColors.textBrandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isRecruiter ? 24.h : 20.h),

            // Login button
            ButtonPrimaryGradient(
              text: 'ĐĂNG NHẬP', 
              onPressed: onLogin,
            ),

            SizedBox(height: 20.h),
            
            if(role == UserRole.candidate.name)...[
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/auth/signup');
                    },
                    child: Text(
                      '  Đăng ký',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.textBrandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}