import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/formatter_service.dart';
import 'package:pinput/pinput.dart';

class CustomPincodeField extends StatelessWidget {
  const CustomPincodeField({
    super.key,
    this.onCompleted,
    this.controller,
    this.focusNode,
    this.enabled = true,
  });
  final void Function(String)? onCompleted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Pinput.builder(
      length: 5,
      separatorBuilder: (_) => SizedBox(width: 12.w), // khoảng cách giữa các ô
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      hapticFeedbackType: HapticFeedbackType.vibrate,
      keyboardType: TextInputType.number,
      onCompleted: onCompleted,
      keyboardAppearance: Brightness.light,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled!,
      inputFormatters: [FormatterService.pinCodeFormatter],
      builder: (context, pinItemBuilderState) => Container(
        width: 44.w,
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: BackgroundColors.backgroundDefaultPrimary,
          border: Border.all(
              width: 1.w,
              color: pinItemBuilderState.value.isNotEmpty
                  ? BorderColors.borderInputFieldDefault
                  : BorderColors.borderSeparatorNonOpaque),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 2.h,
          children: [
            SizedBox(
              height: 2.w,
            ),
            // Number
            Text(pinItemBuilderState.value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 15.sp,
                    )),

            // Divider
            AnimatedOpacity(
                opacity: pinItemBuilderState.value.isEmpty ? 1 : 0,
                duration: Duration(milliseconds: 400),
                child: Container(
                  margin: pinItemBuilderState.value.isEmpty
                      ? EdgeInsets.only(bottom: 12)
                      : EdgeInsets.only(bottom: 0),
                  width: 7.w,
                  height: 1.h,
                  color: TextColors.textDefaultPrimary,
                )),
          ],
        ),
      ),
    );
  }
}
