import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 22.sp),
            onPressed: () => context.pop(),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: IconButton(
            icon: Icon(Icons.person_add, color: Colors.blue, size: 22.sp),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
