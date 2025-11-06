import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? content;
  final bool isLink;

  const CompanyInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp, 
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  content!,
                  style: isLink
                    ? theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      )
                    : theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
