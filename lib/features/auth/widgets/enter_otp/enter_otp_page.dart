// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:job_connect/config/widgets/unfocus_widget.dart';
// import 'package:job_connect/features/auth/screens/enter_otp_form.dart';


// class EnterOtpPage extends StatefulWidget {
//   final String email;
//   final void Function(BuildContext context) onCompleted;

//   const EnterOtpPage({
//       super.key,
//       required this.email,
//       required this.onCompleted,
//     });  

//   @override
//   State<EnterOtpPage> createState() => _EnterOtpPageState();
// }

// class _EnterOtpPageState extends State<EnterOtpPage> {
//   final _otpCodeCon = TextEditingController();
//   final _otpCodeNode = FocusNode();

//   @override
//   void dispose() {
//     _otpCodeCon.dispose();
//     _otpCodeNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return UnfocusWidget(
//       child: BackgroundWidget(
//         title: 'Xác thực tài khoản',
//         child: Container(
//           padding: EdgeInsets.all(16.w),
//           child: BackgroundForm(
//             isOpacity: 0.8,
//             titleForm: 'Nhập mã OTP',
//             child: EnterOtpForm(
//               email: widget.email,
//               onCompleted: widget.onCompleted,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }