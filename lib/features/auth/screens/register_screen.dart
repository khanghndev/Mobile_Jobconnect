import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/formatter_service.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/custom_pass_field_with_label.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/data/models/account_model.dart';
import 'package:job_connect/data/models/role_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/services/auth_firebase_service.dart';

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
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String _selectedCountryCode = '+84';
  bool _isLoading = false;
  bool _isCompletingSignUp = false;
  User? _user;

  final _auth = AuthFirebaseService();
  final _apiService = ApiService( );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.backgroundDefaultPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  SizedBox(height: 16.h),

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
                          AppImages.logo,
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

                  // Họ tên
                  CustomTextFieldWithlabel(
                    controller: _nameController,
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
                  CustomTextFieldWithlabel(
                    controller: _emailController,
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
                          dialogSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            MediaQuery.of(context).size.height * 0.6,
                          ),
                          searchDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            hintText: 'Tìm quốc gia',
                            prefixIcon: const Icon(Icons.search),
                          ),
                          dialogTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          boxDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: BackgroundColors.backgroundInputFieldDefault,
                            boxShadow: [
                              BoxShadow(
                                color: BasicColors.black100.withValues(alpha: 0.1),
                                blurRadius: 10.r,
                                offset: Offset(0, 5.h),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomInputField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hintText: 'Nhập số điện thoại',
                          prefixIcon: Icon(Icons.phone, color: IconColors.iconDefaultPrimary.withValues(alpha: 0.6),),
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

                  // Password fields
                  CustomPassFieldWithLabel(
                    controller: _passwordController,
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

                  CustomPassFieldWithLabel(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu',
                    isObscure: _isObscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _isObscureConfirmPassword = !_isObscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mật khẩu không được bỏ trống';
                      }
                      if (value.trim() != _passwordController.text.trim()) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Checkbox Điều khoản & Điều kiện
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          activeColor: BackgroundColors.backgroundButtonPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Tôi đồng ý với ',
                            style: TextStyle(fontSize: 15.sp, color: TextColors.textDefaultPrimary),
                            children: [
                              TextSpan(
                                text: 'Điều khoản & Điều kiện',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: BackgroundColors.backgroundButtonPrimary,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Nút đăng ký
                  CustomPrimaryButton(
                    text: "ĐĂNG KÝ",
                    onPressed: () => _onEmailPasswordSignUp(context),
                    isLoading: _isLoading,
                    backgroundColor: BackgroundColors.backgroundButtonPrimary,
                    foregroundColor: TextColors.textButtonPrimary,
                    disabledColor: BackgroundColors.backgroundButtonDisabled,
                  ),

                  SizedBox(height: 24.h),

                  // Đã có tài khoản
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(
                          color: TextColors.textDefaultSecondary,
                          fontSize: 15.sp,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: GestureDetector(
                          onTap: () => goToLogin(context),
                          child: Text(
                            ' Đăng nhập',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: BackgroundColors.backgroundButtonPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: BorderColors.borderDefaultDefault, thickness: 1.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Hoặc đăng ký với',
                          style: TextStyle(
                            color: TextColors.textDefaultSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: BorderColors.borderDefaultDefault, thickness: 1.h)),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Google sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _initiateGoogleSignIn(context),
                        child: Container(
                          width: 54.w,
                          height: 54.h,
                          decoration: BoxDecoration(
                            color: BackgroundColors.backgroundDefaultPrimary.withValues(alpha: 0.5),
                            border: Border.all(color: BorderColors.borderDefaultDefault),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: BasicColors.black100.withValues(alpha: 0.1),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/google.png',
                              width: 20.w,
                              height: 20.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Future<void> _onEmailPasswordSignUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đồng ý với điều khoản và điều kiện'),
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          ),
        );
        return;
      }

      final user = await _auth.signupWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại!'),
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          ),
        );
        return;
      }

      _user = user.user;

      final userAccount = Account(
        idUser: _user!.uid,
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _selectedCountryCode + _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        idRole: 'role2',
        accountStatus: 'active',
        avatarUrl: null,
        socialLogin: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        gender: 'other',
        address: null,
        dateOfBirth: null,
        role: Role(idRole: 'role2', roleName: 'Candidate', description: 'Ứng viên'),
      );

      await _apiService.post(
          endpoint: ApiConstants.userEndpoint, 
          body: userAccount.toJson()
        );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thành công!'),
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        ),
      );

      goToLogin(context);
    }
  }

  Future<void> _initiateGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _auth.authGoogle();
      if (userCredential == null || userCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký bằng Google thất bại.'),
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          ),
        );
        return;
      }

      final user = userCredential.user!;
      _user = user;

      final userDoc = await _apiService.get(
          endpoint: '${ApiConstants.userEndpoint}/${user.uid}');
      if (userDoc != null) {
        goToLogin(context);
      } else {
        setState(() {
          _isCompletingSignUp = true;
          _emailController.text = user.email ?? '';
          _nameController.text = user.displayName ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
