import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

/// TextField chung
class CustomTextFieldWithlabel  extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFieldWithlabel ({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3),),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3),
            width: 2.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: 16.w,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}