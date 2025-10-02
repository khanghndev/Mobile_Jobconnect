import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/reset_method.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_appbar.dart';
import 'package:job_connect/config/widgets/custom_pincode_field.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';

class EnterOtpPage extends StatefulWidget {
  final String email;
  final String title;

  const EnterOtpPage({
    super.key,
    required this.email,
    required this.title,
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
    _resendRecognizer = TapGestureRecognizer()..onTap = _handleResend;
    _startCountdown();
  }

  void _handleResend() {
    // chỉ thực hiện khi countdown = 0
    if (_countdown == 0) {
      _startCountdown();
      SnackbarApp.show(
        context,
        title: "Thành công",
        message: 'Mã OTP đã được gửi lại',
        backgroudColor: BackgroundColors.backgroundSuccessPrimary,
      );
      // TODO: gọi API gửi lại OTP ở đây nếu cần
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = 1;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() {}); // để build lại và hiển thị nút Gửi lại
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _verifyOtp(BuildContext context, String otp) async {
    // Ví dụ xử lý tạm thời: chỉ chấp nhận "11111"
    setState(() {
      _isVerifying = true;
      _errorText = '';
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (otp == '11111') {
      setState(() {
        _isVerifying = false;
      });
      
      if(context.mounted) {
        SnackbarApp.show(
          context,
          title: "Thành công",
          message: '${widget.title} thành công',
          backgroudColor: BackgroundColors.backgroundSuccessPrimary,
        );
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      setState(() {
        _isVerifying = false;
        _errorText = 'Mã OTP không đúng. Vui lòng thử lại.';
      });
      // Xoá input để người dùng nhập lại
      _otpCodeCon.clear();
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
                    _verifyOtp(context, otp);
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
        
                // Error text (chỉ hiển thị khi có lỗi)
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
    );
  }
}
