import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    titleIcon,
                    color: theme.colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
        
            //  Divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Divider(
                color: theme.dividerColor.withValues(alpha: 0.5),
                height: 1,
              ),
            ),
        
            //  Children widgets
            ...children,
          ],
        ),
      ),
    );
  }
}
