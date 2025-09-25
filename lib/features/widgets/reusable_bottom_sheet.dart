import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterOption {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor; // màu icon tùy chỉnh
  final VoidCallback? onTapItem; // callback khi nhấn vào item

  FilterOption({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTapItem,
  });
}

class ReusableBottomSheet extends StatefulWidget {
  final List<FilterOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final String? headerTitle;
  final IconData? headerIcon;
  final bool showRadio; // có hiển thị radio không

  const ReusableBottomSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.headerTitle,
    this.headerIcon,
    this.showRadio = true,
  });

  @override
  State<ReusableBottomSheet> createState() => _ReusableBottomSheetState();
}

class _ReusableBottomSheetState extends State<ReusableBottomSheet> {
  late String currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.headerTitle != null)
            ListTile(
              leading: widget.headerIcon != null
                  ? Icon(widget.headerIcon, size: 24.sp)
                  : null,
              title: Text(
                widget.headerTitle!,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ...widget.options.map((option) {
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon,
                    size: 24.sp, color: option.iconColor ?? Colors.black),
              ),
              title: Text(option.title, style: TextStyle(fontSize: 16.sp)),
              trailing: widget.showRadio
                  ? Radio<String>(
                      value: option.value,
                      groupValue: currentValue,
                      onChanged: (v) {
                        setState(() => currentValue = v!);
                        widget.onSelected(v!);
                        option.onTapItem?.call();
                        Navigator.of(context).pop();
                      },
                    )
                  : null,
              onTap: () {
                if (widget.showRadio) {
                  setState(() => currentValue = option.value);
                  widget.onSelected(option.value);
                } else {
                  widget.onSelected(option.value);
                }
                option.onTapItem?.call();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
