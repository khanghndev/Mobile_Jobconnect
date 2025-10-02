import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReasonWrap extends StatelessWidget {
  final List<String> reasons;
  final String? selected;
  final ValueChanged<String> onSelected;

  const ReasonWrap({
    super.key,
    required this.reasons,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: reasons.map((r) {
        final isSel = r == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: () => onSelected(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.r),
              color: isSel
                  ? theme.colorScheme.primary
                  : Colors.white.withValues(alpha:0.8),
              border: Border.all(
                color: isSel
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha:0.2),
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha:0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSel ? Icons.check_circle : Icons.circle_outlined,
                  size: 16.sp,
                  color: isSel ? Colors.white : theme.colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  r,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
