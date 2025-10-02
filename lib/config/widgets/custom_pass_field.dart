import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'custom_adaptive_tap_effect.dart';
import 'custom_input_field.dart';

class CustomPassField extends StatelessWidget {
  const CustomPassField({
    super.key,
    this.focusNode,
    this.controller,
    this.hintText,
    this.onEditingComplete,
    this.textInputAction,
    this.validator,
    this.showPrefixIcon = true,
  });
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? hintText;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool showPrefixIcon;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      hintText: hintText,
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      validator: validator,
      prefixIcon: showPrefixIcon
          ? Icon(
              Icons.key,
              size: 22.sp,
              color: IconColors.iconInputFieldLeadingIcon,
            )
          : null,
      suffixIcon: CustomAdaptiveTapEffect(
        onPressed: () {},
        child: Icon(
         true ? Icons.visibility : Icons.visibility_off,
          color: IconColors.iconDefaultSecondary,
          size: 22.sp,
        ),
      ),
    );
  }
}
