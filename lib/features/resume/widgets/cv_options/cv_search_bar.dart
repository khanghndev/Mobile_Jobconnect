import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef OnSearchChanged = void Function(String value);
typedef OnMenuSelected = void Function(String value);

class CVSearchBar extends StatelessWidget {
  final OnSearchChanged onSearchChanged;
  final OnMenuSelected onMenuSelected;

  const CVSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên CV...',
                hintStyle: TextStyle(
                  color: theme.hintColor.withValues(alpha: 0.6),
                  fontSize: 15.5.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.primaryColor.withValues(alpha: 0.8),
                  size: 24.sp,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 26.sp,
              ),
              tooltip: 'Tùy chọn & Sắp xếp',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 3,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildPopupMenuItem(
                  Icons.sort_by_alpha_rounded,
                  'Sắp xếp: Tên (A-Z)',
                  'sort_name',
                  theme,
                ),
                _buildPopupMenuItem(
                  Icons.date_range_rounded,
                  'Sắp xếp: Ngày tạo',
                  'sort_date',
                  theme,
                ),
                const PopupMenuDivider(height: 1),
                _buildPopupMenuItem(
                  Icons.filter_alt_off_outlined,
                  'Lọc CV (Nâng cao)',
                  'filter',
                  theme,
                ),
                _buildPopupMenuItem(
                  Icons.help_outline_rounded,
                  'Trợ giúp',
                  'help',
                  theme,
                ),
              ],
              onSelected: onMenuSelected,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    IconData icon,
    String text,
    String value,
    ThemeData theme,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22.sp,
          ),
          SizedBox(width: 14.w),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}