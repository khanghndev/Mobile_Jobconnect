import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final ValueChanged<int>? onSelected;

  /// Colors
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color borderColor;

  const CategoryChips({
    super.key,
    required this.categories,
    this.initialIndex = 0,
    this.onSelected,
    this.selectedColor = Colors.white,
    this.unselectedColor = const Color.fromRGBO(255, 255, 255, 0.05),
    this.selectedTextColor = Colors.black,
    this.unselectedTextColor = Colors.white,
    this.borderColor = Colors.white,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h, // cố định chiều cao chip row
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final label = widget.categories[index];
          final isSelected = index == selectedIndex;

          return Row(
            children: [
              if (index == 0) SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onSelected?.call(index);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.w,
                      color: widget.borderColor,
                    ),
                    color: isSelected ? widget.selectedColor : widget.unselectedColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected ? widget.selectedTextColor : widget.unselectedTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (index == widget.categories.length - 1) SizedBox(width: 12.w),
            ],
          );
        },
      ),
    );
  }
}