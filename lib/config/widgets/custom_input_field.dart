import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.hintText,
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onEditingComplete,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.prefixIcon,
    this.fillColor,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.counter,
    this.counterText,
    this.enabled,
    this.maxLength,
    this.hintStyle,
    this.borderColor, // mới
  });

  final String? hintText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color? borderColor; // mới
  final TextAlign textAlign;
  final void Function(String)? onChanged;
  final Widget? counter;
  final String? counterText;
  final bool? enabled;
  final int? maxLength;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      maxLines: maxLines,
      readOnly: readOnly,
      obscureText: obscureText,
      focusNode: focusNode,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      validator: (value) => validator?.call(value),
      maxLength: maxLength,
      minLines: minLines,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      autofillHints: null,
      decoration: InputDecoration(
        counter: counter,
        counterText: counterText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: fillColor != null,
        fillColor: fillColor ?? BackgroundColors.backgroundDefaultPrimary,
        hintStyle: hintStyle ??
            TextStyle(
              fontSize: 17.sp,
              color: TextColors.textDefaultTertiary.withValues(alpha: 0.3),
            ),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3),),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3),),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: 2.w,
          ),
        ),
      ),
    );
  }
}
