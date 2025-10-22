import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/auth/widgets/register/register_form.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final String _selectedCountryCode = '+84';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void goToLogin(BuildContext context) {
    context.push(
      '/auth/login', 
      extra: {
        'role': UserRole.candidate.name
      }
    );
  }

  Future<void> _onRegisterWithGoogle(BuildContext context) async {
    
  }

  Future<void> _onRegister(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();

    await authVM.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _selectedCountryCode + _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      comfirmPassword: _confirmPasswordController.text.trim(),
    );

    if (authVM.errorMessage != null && context.mounted) {
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: authVM.errorMessage!,
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    } else {
      if(context.mounted){
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Đăng kí thành công',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
        goToLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: BackgroundColors.backgroundDefaultPrimary,
      body: UnfocusWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  // Nút quay lại
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        getAdaptiveBackIcon(context),
                        color: IconColors.iconDefaultPrimary,
                        size: 22.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  // Logo
                  Center(
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: BasicColors.black100.withValues(alpha: 0.1),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.logoApp,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Tiêu đề
                  Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: TextColors.textDefaultPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  // Phụ đề
                  Text(
                    'Hãy điền thông tin cá nhân để đăng ký',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: TextColors.textDefaultSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  RegisterForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isLoading: authVM.isLoading,
                    onRegister: () => _onRegister(context),
                    onRegisterWithGoogle: () => _onRegisterWithGoogle(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}