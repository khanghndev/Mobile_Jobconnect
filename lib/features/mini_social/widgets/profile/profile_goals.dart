import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileGoals extends StatelessWidget {
  final int posts;
  final int likes;
  final int shared;
  final int followers;

  const ProfileGoals({
    super.key,
    required this.posts,
    required this.likes,
    required this.shared,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildGoal(Icons.post_add_outlined, posts.toString(), "Bài viết", Colors.purple),
        _buildGoal(Icons.favorite_rounded, likes.toString(), "Lượt thích", Colors.red),
        _buildGoal(Icons.save_alt, shared.toString(), "Lượt lưu", Colors.amber),
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
        Text(
          value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
