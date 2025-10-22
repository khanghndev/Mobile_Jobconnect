import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterChipFile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final ThemeData theme;

  const FilterChipFile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha:
          isSelected ? 0.3 : 0.6,
        ),
        selectedColor: theme.colorScheme.primaryContainer,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color:
              isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha:0.9),
          fontWeight:
              isSelected
                  ? FontWeight.bold
                  : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color:
                isSelected
                    ? theme.colorScheme.primary.withValues(alpha:0.6)
                    : theme.dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 9.h,
        ),
        showCheckmark: false,
        elevation: isSelected ? 1.5 : 0.5,
        selectedShadowColor: theme.colorScheme.primary.withValues(alpha:0.2),
      ),
    );
  }
}