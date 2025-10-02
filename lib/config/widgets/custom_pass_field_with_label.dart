import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// TextField mật khẩu
class CustomPassFieldWithLabel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isObscure;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const CustomPassFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    required this.isObscure,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
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
