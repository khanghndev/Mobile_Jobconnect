import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomTextFieldWithLabel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final String? hintText;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int maxLines; 
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? borderColor;
  final Color? hintTextColor;
  final Color? labelTextColor;
  final double? borderRadius;

  const CustomTextFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator, 
    this.fillColor, 
    this.hintText, 
    this.prefixIconColor, 
    this.suffixIconColor,
    this.onTap,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.inputFormatters,
    this.contentPadding,
    this.borderColor,
    this.hintTextColor,
    this.labelTextColor,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
        prefixIcon: Icon(icon, size: 20.sp),
        prefixIconColor: prefixIconColor ?? theme.iconTheme.color,
        suffixIcon: suffixIcon != null
          ? GestureDetector(
              onTap: onSuffixIconTap,
              child: Icon(suffixIcon),
            )
          : null,
        suffixIconColor: suffixIconColor ?? theme.iconTheme.color,
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
            color: theme.primaryColor,
            width: 2.w,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
