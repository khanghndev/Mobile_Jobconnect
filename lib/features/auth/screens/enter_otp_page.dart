import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/otp_action_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/custom_pincode_field.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

class EnterOtpPage extends StatefulWidget {
  final String title;
  final String email;
  final String? password;
  final String? fullName;
  final String? phoneNumber;
  final String? confirmPassword;
  final OtpActionType actionType;

  const EnterOtpPage({
    super.key,
    required this.email,
    required this.title,
    this.password,
    this.confirmPassword,
    this.fullName,
    this.phoneNumber,
    required this.actionType,
  });

  @override
  State<EnterOtpPage> createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  final _otpCodeCon = TextEditingController();
  Timer? _timer;
  int _countdown = 60;
  String _errorText = '';
  bool _isVerifying = false;
  late TapGestureRecognizer _resendRecognizer;

  @override
  void initState() {
    super.initState();
    _resendRecognizer = TapGestureRecognizer()..onTap = _onResendOtp;
    _onStartCountdown();
  }

  void onGoToLogin() {
    context.push(
      '/auth/login',
      extra: {'role': UserRole.candidate.name},
    );
  }

  void _onResendOtp() async{
    _otpCodeCon.clear();
    if (_countdown == 0) {
      final authVM = context.read<AuthViewModel>();

      try {
        await authVM.resendOtp(widget.email);
        if (mounted) {
          SnackbarApp.show(
            context,
            title: "Thành công",
            message: 'Mã OTP đã được gửi lại',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
          );
        }
        _onStartCountdown();
      } catch (e) {
        if (mounted) {
          SnackbarApp.show(
            context,
            title: "Lỗi",
            message: 'Không thể gửi lại mã OTP: $e',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      }
    }
  }

  void _onStartCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _onVerifyOtp(BuildContext context, String otp) async {
    final authVM = context.read<AuthViewModel>();

    setState(() {
      _isVerifying = true;
      _errorText = '';
    });
    if(widget.actionType == OtpActionType.register){
      await authVM.verifyOtp(email: widget.email, code: otp);
    }
    else if(widget.actionType == OtpActionType.resetPass){
      await authVM.verifyOtpReset(email: widget.email, code: otp);
    }

    if (authVM.errorMessage != null) {
      setState(() {
        _isVerifying = false;
        _errorText = authVM.errorMessage!;
      });
      _otpCodeCon.clear();
      return;
    }

    // Xử lý theo loại hành động
    switch (widget.actionType) {
      case OtpActionType.register:
        await authVM.register(
          name: widget.fullName!,
          email: widget.email,
          phone: widget.phoneNumber!,
          password: widget.password!,
          confirmPassword: widget.confirmPassword!,
        );
        break;

      case OtpActionType.resetPass:
        if(context.mounted){
          context.push(
            '/auth/reset-password', 
            extra: {
              'email': widget.email
            }
          );
        }
        break;
    }

    setState(() {
      _isVerifying = false;
    });

    if (!context.mounted) return;

    if (authVM.errorMessage != null) {
      SnackbarApp.show(
        context,
        title: 'Lỗi',
        message: authVM.errorMessage!,
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    } else if (authVM.isSuccess) {
      SnackbarApp.show(
        context,
        title: 'Thành công',
        message: widget.actionType == OtpActionType.register
            ? 'Đăng ký thành công'
            : 'Xác thực thành công',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );

      if (widget.actionType == OtpActionType.register) {
        onGoToLogin();
      }
    }
  }

  @override
  void dispose() {
    _resendRecognizer.dispose();
    _timer?.cancel();
    _otpCodeCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppbar(
        automaticallyImplyLeading: true,
        title: Text(
          'Xác thực tài khoản',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: TextColors.textBrandOnbrand,
          ),
        ),
        leading: CustomAdaptiveTapEffect(
          isOpacity: true,
          onPressed: () => context.pop(),
          child: Icon(
            getAdaptiveBackIcon(context),
            size: 22.sp,
            color: IconColors.iconBrandOnbrand,
          ),
        ),
      ),
      body: UnfocusWidget(
        child: OverlayLoading(
          isLoading: _isVerifying,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  20.verticalSpace,
                  // Icon
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BackgroundColors.backgroundBrandPrimary.withValues(alpha: 0.3),
                          blurRadius: 10.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45.r,
                      backgroundColor: BackgroundColors.backgroundBrandPrimary,
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 50.sp,
                        color: IconColors.iconBrandOnbrand,
                      ),
                    ),
                  ),
                  30.verticalSpace,
                  Text(
                    'Nhập mã OTP để ${widget.title.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textBrandPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  16.verticalSpace,
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                      ),
                      children: [
                        TextSpan(
                          text: 'Vui lòng nhập mã otp để ${widget.title.toLowerCase()}\n',
                        ),
                        const TextSpan(text: 'Chúng tôi đã gửi mã otp đến '),
                        TextSpan(
                          text: widget.email,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: TextColors.textDefaultPrimary.withValues(alpha: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
          
                  // Pin code field
                  CustomPincodeField(
                    controller: _otpCodeCon,
                    onCompleted: (otp) {
                      _onVerifyOtp(context, otp);
                    },
                  ),
                  SizedBox(height: 12.h),
          
                  // loading nhỏ khi verify
                  if (_isVerifying)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
          
                  SizedBox(height: 12.h),
          
                  // Resend OTP / countdown or clickable "Gửi lại" (chỉ chữ gửi lại có sự kiện)
                  if (_countdown > 0)
                    Text(
                      "Gửi lại sau $_countdown giây",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.sp,
                            color: TextColors.textDefaultSecondary,
                          ),
                    )
                  else
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                          color: TextColors.textDefaultSecondary,
                        ),
                        children: [
                          const TextSpan(text: "Bạn không nhận được mã? "),
                          TextSpan(
                            text: "Gửi lại",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                            recognizer: _resendRecognizer,
                          ),
                        ],
                      ),
                    ),
          
                  if (_errorText.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Text(
                      _errorText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.08,
                        height: 18 / 13,
                        color: TextColors.textErrorPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
