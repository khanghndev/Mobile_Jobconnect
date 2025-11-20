import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  final bool isCurrentUser;
  final bool? isFriend; // true: bạn bè, false: chưa kết bạn, null: đang load
  final bool isLoading;
  final VoidCallback? onAddFriend;
  final VoidCallback onBack;

  const ProfileHeader({
    super.key,
    required this.isCurrentUser,
    this.isFriend,
    this.isLoading = false,
    this.onAddFriend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha:0.1),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue,
              size: 22.sp,
            ),
            onPressed: onBack,
          ),
        ),

        // // Nút kết bạn chỉ hiển thị nếu không phải user hiện tại
        // if (!isCurrentUser)
        //   CircleAvatar(
        //     backgroundColor: Colors.blue.withValues( alpha: 0.1),
        //     child: isLoading
        //         ? SizedBox(
        //             width: 24.w,
        //             height: 24.w,
        //             child: const CircularProgressIndicator(strokeWidth: 2),
        //           )
        //         : IconButton(
        //             icon: Icon(
        //               isFriend == true
        //                   ? Icons.person_remove // Hủy kết bạn
        //                   : Icons.person_add, // Kết bạn
        //               color: Colors.blue,
        //               size: 22.sp,
        //             ),
        //             onPressed: onAddFriend,
        //           ),
        //   ),
      ],
    );
  }
}
