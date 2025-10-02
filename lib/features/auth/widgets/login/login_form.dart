import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';
import 'package:job_connect/features/auth/screens/forgot_password_screen.dart';
import 'package:job_connect/features/auth/screens/register_screen.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final passwordVisible = ValueNotifier<bool>(false);
    final rememberMe = ValueNotifier<bool>(false);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  getAdaptiveBackIcon(context),
                  color: IconColors.iconBrandPrimary,
                  size: 22.sp,
                ),
                onPressed: onBack,
              ),
            ),

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
                  AppImages.logo,
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
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập Email',
                labelStyle: TextStyle(color: const Color(0xFF1976D2), fontSize: 14.sp),
                prefixIcon: Icon(Icons.email, color: const Color(0xFF1976D2), size: 20.sp),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.blue.withValues(alpha: 0.05),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Password field
            ValueListenableBuilder<bool>(
              valueListenable: passwordVisible,
              builder: (_, visible, __) {
                return TextFormField(
                  controller: passwordController,
                  obscureText: !visible,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    labelStyle: TextStyle(color: const Color(0xFF1976D2), fontSize: 14.sp),
                    prefixIcon: Icon(Icons.lock, color: const Color(0xFF1976D2), size: 20.sp),
                    suffixIcon: IconButton(
                      icon: Icon(
                        visible ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF1976D2),
                        size: 20.sp,
                      ),
                      onPressed: () => passwordVisible.value = !visible,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.blue.withValues(alpha: 0.05),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                );
              },
            ),

            SizedBox(height: 8.h),

            // Remember + Forgot password
            Row(
              children: [
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
            CustomPrimaryButton(
              text: "ĐĂNG NHẬP",
              onPressed: onLogin,
              isLoading: isLoading,
              backgroundColor: BackgroundColors.backgroundButtonPrimary,
              foregroundColor: TextColors.textBrandOnbrand,
              disabledColor: BackgroundColors.backgroundButtonPrimary.withValues(alpha: 0.5),
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
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const RegisterScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: Text(
                    '  Đăng ký ngay',
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