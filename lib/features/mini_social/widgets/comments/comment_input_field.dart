import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback? onSend;
  final ValueChanged<String>? onChanged;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.hasText,
    required this.onSend,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.camera_alt_outlined, size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            onChanged: onChanged, 
            decoration: InputDecoration(
              hintText: "Nhập bình luận...",
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gif_box_outlined, color: Colors.grey, size: 20.sp),
                  SizedBox(width: 8.w),
                  Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 20.sp),
                  SizedBox(width: 8.w),
                ],
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: hasText ? onSend : null,
          icon: Icon(
            Icons.send,
            color: hasText ? Colors.blue : Colors.grey,
            size: 20.sp,
          ),
        ),
      ],
    );
  }
}