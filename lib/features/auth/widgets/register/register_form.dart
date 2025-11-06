import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/formatter_service.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_pass_field_with_label.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final Future<void> Function() onRegister;
  final Future<void> Function() onRegisterWithGoogle;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
    required this.onRegisterWithGoogle,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isAgreeToTerms = false;
  String _selectedCountryCode = '+84';

  void _onRegister() async {
    if (widget.formKey.currentState!.validate()) {
      if (!_isAgreeToTerms) {
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Vui lòng đồng ý với điều khoản và điều kiện',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
        
        return;
      }
      await widget.onRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Họ tên
          CustomTextFieldWithLabel(
            labelTextColor: theme.hintColor.withValues(alpha: 0.5), 
            controller: widget.nameController,
            label: 'Họ và tên',
            icon: Icons.person_outline,
            validator: (value) => InputValidators.validate(
              value: value,
              hintText: 'Họ và tên',
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(height: 16.h),

          // Email
          CustomTextFieldWithLabel(
            labelTextColor: theme.hintColor.withValues(alpha: 0.5), 
            controller: widget.emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => InputValidators.validate(
              value: value,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          SizedBox(height: 16.h),

          // Số điện thoại + mã quốc gia
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 58.h,
                decoration: BoxDecoration(
                  color: BackgroundColors.backgroundInputFieldDefault,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: BorderColors.borderInputFieldDefault.withValues(alpha: 0.3),
                  ),
                ),
                child: CountryCodePicker(
                  onChanged: (countryCode) {
                    setState(() {
                      _selectedCountryCode = countryCode.dialCode ?? '+84';
                    });
                  },
                  initialSelection: 'VN',
                  favorite: const ['VN','US','CN','JP','KR','SG','TH'],
                  flagWidth: 20.w,
                  padding: EdgeInsets.zero,
                  showDropDownButton: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomTextFieldWithLabel(
                  labelTextColor: theme.hintColor.withValues(alpha: 0.5), 
                  controller: widget.phoneController,
                  keyboardType: TextInputType.phone,
                  hintText: 'Nhập số điện thoại',
                  label: 'Số điện thoại',
                  icon: Icons.phone,
                  fillColor: BackgroundColors.backgroundInputFieldDefault,
                  inputFormatters: [FormatterService.phoneFormatter],
                  contentPadding: EdgeInsets.all(16.w),
                  borderColor: BorderColors.borderInputFieldDefault,
                  validator: (value) => InputValidators.validate(
                    value: value,
                    hintText: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Password
          CustomPassFieldWithLabel(
            labelTextColor: theme.hintColor.withValues(alpha: 0.5), 
            controller: widget.passwordController,
            label: 'Mật khẩu',
            isObscure: _isObscurePassword,
            onToggleVisibility: () {
              setState(() {
                _isObscurePassword = !_isObscurePassword;
              });
            },
            validator: (value) => InputValidators.validate(
              value: value,
              hintText: 'Mật khẩu',
            ),
          ),
          SizedBox(height: 16.h),

          // Confirm Password
          CustomPassFieldWithLabel(
            labelTextColor: theme.hintColor.withValues(alpha: 0.5), 
            controller: widget.confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            isObscure: _isObscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _isObscureConfirmPassword = !_isObscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mật khẩu không được bỏ trống';
              if (value.trim() != widget.passwordController.text.trim()) return 'Mật khẩu không khớp';
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Checkbox Điều khoản
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: _isAgreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _isAgreeToTerms = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  activeColor: BackgroundColors.backgroundButtonPrimary,
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Tôi đồng ý với ',
                    style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Điều khoản & Điều kiện',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: BackgroundColors.backgroundButtonPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Nút đăng ký
          ButtonPrimaryGradient(
            text: "ĐĂNG KÝ",
            onPressed: _onRegister,
          ),
          SizedBox(height: 24.h),

          // Divider + Google
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey, thickness: 1.h)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('Hoặc đăng ký với', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              ),
              Expanded(child: Divider(color: Colors.grey, thickness: 1.h)),
            ],
          ),
          SizedBox(height: 24.h),

          // Google sign-up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: widget.onRegisterWithGoogle,
                child: Container(
                  width: 54.w,
                  height: 54.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(child: Image.asset(AppImages.google, width: 20.w, height: 20.h)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
