import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/reusable_bottom_sheet.dart';

class GroupFilterHeader extends StatelessWidget {
  final String selectedFilter;
  final List<FilterOption> filterOptions;
  final ValueChanged<String> onSelected;
  final IconData headerIcon;

  const GroupFilterHeader({
    super.key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSelected,
    this.headerIcon = Icons.filter_list,
  });

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => ReusableBottomSheet(
        headerIcon: headerIcon,
        options: filterOptions,
        selectedValue: selectedFilter,
        showRadio: true,
        onSelected: (value) => onSelected(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),  
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedFilter,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, size: 22.sp, color: Colors.black87),
            onPressed: () => _openFilterSheet(context),
          ),
        ],
      ),
    );
  }
}