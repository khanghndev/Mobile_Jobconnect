import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStat(Icons.person_add, "4.5k \nfollowers", Colors.white, Colors.blue),
        SizedBox(width: 40.w),
        _buildStat(Icons.thumb_up, "4.5k \nlikes", Colors.orange, Colors.white),
      ],
    );
  }

  Widget _buildStat(IconData icon, String text, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(width: 6.w),
        Text(text, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }
}
