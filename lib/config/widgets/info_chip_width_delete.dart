import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoChipWidthDelete extends StatelessWidget {
  final String tag;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;

  const InfoChipWidthDelete({
    super.key,
    required this.tag,
    this.onDeleted,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        "#$tag", 
        style: TextStyle(fontSize: 14.sp)
      ),
      onDeleted: onDeleted,
      iconTheme: IconThemeData(size: 20.sp, color: Colors.red),
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}