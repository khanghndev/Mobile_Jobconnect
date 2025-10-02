import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: Icons.message_outlined,
          label: "Nhắn tin",
          bgColor: Colors.white,
          fgColor: Colors.black,
        ),
        SizedBox(width: 12.w),
        _buildButton(
          label: "Theo dõi",
          bgColor: Colors.blue,
          fgColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildButton({
    IconData? icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          minimumSize: Size(120.w, 44.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () {},
        icon: icon != null ? Icon(icon, size: 18.sp) : const SizedBox(),
        label: Text(label, style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }
}
