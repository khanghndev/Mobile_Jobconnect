import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileGoals extends StatelessWidget {
  const ProfileGoals({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildGoal(Icons.post_add_outlined, "25", "Số bài viết", Colors.purple),
        _buildGoal(Icons.remove_red_eye, "210", "Số người xem", Colors.orange),
        _buildGoal(Icons.save_alt, "135", "Lượt lưu", Colors.amber),
      ],
    );
  }

  Widget _buildGoal(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 4.w),
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }
}
