import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStats extends StatelessWidget {
  final int followers;
  final int likes;

  const ProfileStats({
    super.key,
    this.followers = 0,
    this.likes = 0,
  });

  // ✅ Format số
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStat(
          Icons.person_add,
          "${_formatCount(followers)}\nfollowers",
          Colors.blue,
          Colors.white,
        ),
        SizedBox(width: 40.w),
        _buildStat(
          Icons.thumb_up,
          "${_formatCount(likes)}\nthích",
          Colors.orange,
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildStat(
    IconData icon,
    String text,
    Color bgColor,
    Color iconColor,
  ) {
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
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}