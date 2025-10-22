import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/resume/widgets/cv_options/filter_chip_file.dart';

class CvCountAndFilters extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const CvCountAndFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  FilterChipFile(
                    label: 'Tất cả',
                    isSelected: selectedFilter == 'Tất cả',
                    onSelected: (selected) {
                      if (selected) onFilterSelected('Tất cả');
                    },
                    theme: theme,
                  ),
                  FilterChipFile(
                    label: 'PDF',
                    isSelected: selectedFilter == 'PDF',
                    onSelected: (selected) {
                      if (selected) onFilterSelected('PDF');
                    },
                    theme: theme,
                  ),
                  FilterChipFile(
                    label: 'Word',
                    isSelected: selectedFilter == 'Word',
                    onSelected: (selected) {
                      if (selected) onFilterSelected('Word');
                    },
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}