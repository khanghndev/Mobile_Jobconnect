import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_pass_field_with_label.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';
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

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onBack,
    this.isRemmeber = true
  });

  @override
  Widget build(BuildContext context) {
    final passwordVisible = ValueNotifier<bool>(false);
    final rememberMe = ValueNotifier<bool>(false);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: IconButton(
            //     icon: Icon(
            //       getAdaptiveBackIcon(context),
            //       color: IconColors.iconBrandPrimary,
            //       size: 22.sp,
            //     ),
            //     onPressed: onBack,
            //   ),
            // ),

            SizedBox(height: 8.h,),
            // Logo   
            Container(
              decoration: BoxDecoration(
                color: BackgroundColors.backgroundDefaultPrimary,
                borderRadius: BorderRadius.circular(130.r),
                boxShadow: [
                  BoxShadow(
                    color: BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AppImages.logoApp,
                  width: 120.w,
                  height: 120.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    FontAwesomeIcons.userTie,
                    size: 60.sp,
                    color: IconColors.iconBrandPrimary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'Đăng nhập',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: TextColors.textBrandPrimary,
              ),
            ),

            SizedBox(height: 20.h),

            // Email field
            CustomTextFieldWithLabel(
              controller: emailController,
              label: 'Email',
              hintText: 'Nhập email',
              fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
              prefixIconColor: theme.colorScheme.primary,
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              borderRadius: 16.r,
              icon: Icons.email,
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
                  fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                  prefixIconColor: theme.colorScheme.primary,
                  suffixIconColor: theme.colorScheme.primary,
                  borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: 16.r,
                );
              },
            ),

            SizedBox(height: 8.h),

            // Remember + Forgot password
            Row(
              children: [
                if(isRemmeber == true)...[
                  ValueListenableBuilder<bool>(
                    valueListenable: rememberMe,
                    builder: (_, checked, __) {
                      return Checkbox(
                        value: checked,
                        activeColor: const Color(0xFF1976D2),
                        onChanged: (value) => rememberMe.value = value ?? false,
                      );
                    },
                  ),
                  Text(
                    'Nhớ tài khoản',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.textBrandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Login button
           ButtonPrimaryGradient(
            text: 'ĐĂNG NHẬP', 
            onPressed: onLogin
          ),

            SizedBox(height: 20.h),

            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
        ),
      ),
    );
  }
}