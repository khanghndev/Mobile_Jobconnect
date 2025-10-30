import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomPassFieldWithLabel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isObscure;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final Color? hintTextColor;
  final Color? labelTextColor;
  final Color? borderColor;
  final Color? fillColor;
  final double? borderRadius;
  final String? hintText;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;

  const CustomPassFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    required this.isObscure,
    required this.onToggleVisibility,
    this.validator,
    this.hintTextColor,
    this.labelTextColor,
    this.borderColor,
    this.fillColor,
    this.borderRadius,
    this.hintText,
    this.prefixIconColor,
    this.suffixIconColor,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      onTap: onTap,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: hintTextColor ?? theme.hintColor.withValues(alpha: 0.5),
          fontSize: 16.sp,
        ),
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: labelTextColor ?? theme.colorScheme.primary,
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(
          Icons.lock,
          size: 20.sp,
          color: prefixIconColor ?? theme.iconTheme.color,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: suffixIconColor ?? theme.iconTheme.color,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: 16.w,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: borderColor ?? BorderColors.borderDefaultDefault.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: borderColor ?? BorderColors.borderDefaultDefault.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.w,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}