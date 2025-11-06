import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/custom_pass_field_with_label.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordCon = TextEditingController();
  final TextEditingController _confirmPasswordCon = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  bool _isLoading = false;

  final String title = 'Đặt lại mật khẩu';

  @override
  void dispose() {
    _passwordCon.dispose();
    _confirmPasswordCon.dispose();
    super.dispose();
  }

  Future<void> _onResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    setState(() => _isLoading = true);

    await authVM.resetPassword(
      email: widget.email,
      newPassword: _passwordCon.text.trim(),
      confirmPassword: _confirmPasswordCon.text.trim(),
    );

    setState(() => _isLoading = false);

    if (authVM.isSuccess) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thành công',
          message: 'Đặt lại mật khẩu thành công!',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
        context.go('/auth/login');
      }
    } else {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: authVM.errorMessage!,
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OverlayLoading(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: CustomAppbar(
          automaticallyImplyLeading: true,
          title: Text(
            title,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: TextColors.textBrandOnbrand,
            ),
          ),
          leading: CustomAdaptiveTapEffect(
            isOpacity: true,
            onPressed: () {
              context.go(
                '/auth/login', 
                extra: {
                  'role': UserRole.candidate.name
                }
              );
            },
            child: Icon(
              getAdaptiveBackIcon(context),
              size: 22.sp,
              color: IconColors.iconBrandOnbrand,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  CircleAvatar(
                    radius: 45.r,
                    backgroundColor: BackgroundColors.backgroundBrandPrimary,
                    child: Icon(
                      Icons.lock_reset,
                      size: 50.sp,
                      color: IconColors.iconBrandOnbrand,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'Đặt lại mật khẩu',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textBrandPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),

                  Text(
                    'Nhập mật khẩu mới cho tài khoản ${widget.email}.',
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  CustomPassFieldWithLabel(
                    isObscure: _isObscurePassword,
                    controller: _passwordCon,
                    label: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới',
                    fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    prefixIconColor: theme.colorScheme.primary,
                    borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: 16.r,
                    onToggleVisibility: () {
                      setState(() => _isObscurePassword = !_isObscurePassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  CustomPassFieldWithLabel(
                    isObscure: _isObscureConfirmPassword,
                    controller: _confirmPasswordCon,
                    label: 'Xác nhận mật khẩu',
                    hintText: 'Nhập lại mật khẩu mới',
                    fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    prefixIconColor: theme.colorScheme.primary,
                    borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: 16.r,
                    onToggleVisibility: () {
                      setState(() => _isObscureConfirmPassword = !_isObscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (value != _passwordCon.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),

                  ButtonPrimaryGradient(
                    text: 'ĐỔI MẬT KHẨU',
                    onPressed: _onResetPassword,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}