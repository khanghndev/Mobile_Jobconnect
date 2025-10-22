import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBarMain extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? hinText;

  const CustomSearchBarMain({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.hinText
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hinText ?? "Chưa có hintext",
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor.withValues(alpha: 0.5),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: Icon(
              Icons.search_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear!();
                  },
                  splashRadius: 20,
                )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: 2.w,
            ),
          ),
        ),
      ),
    );
  }
}
