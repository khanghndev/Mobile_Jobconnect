import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentFilterDropdown extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final void Function(String?) onChanged;

  const CommentFilterDropdown({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.arrow_drop_down),
      items: filters.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14.sp)))).toList(),
      onChanged: onChanged,
    );
  }
}
