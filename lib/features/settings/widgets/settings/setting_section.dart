import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingSection extends StatelessWidget {
  final List<Widget> children;
  final bool? isDivider;
  const SettingSection({super.key, required this.children, this.isDivider = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:
              theme.brightness == Brightness.dark ? 0.15 : 0.06,
            ),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1 && isDivider == true)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(
                    height: 0.5.h,
                    thickness: 0.5.h,
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
