import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePostBox extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final String userLevel; // "VIP", "Premium", "Normal"
  final VoidCallback onPost;

  const CreatePostBox({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.userLevel,
    required this.onPost,
  });

  Color _getLevelColor() {
    switch (userLevel.toLowerCase()) {
      case "vip":
        return Colors.amber;
      case "premium":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(width: 10.w),

            /// Nội dung bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tên + Badge cấp
                  // Row(
                  //   children: [
                  //     Text(
                  //       userName,
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 14.sp,
                  //       ),
                  //     ),
                  //     SizedBox(width: 6.w),
                  //     Container(
                  //       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  //       decoration: BoxDecoration(
                  //         color: _getLevelColor().withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(8.r),
                  //         border: Border.all(color: _getLevelColor()),
                  //       ),
                  //       child: Text(
                  //         userLevel,
                  //         style: TextStyle(
                  //           fontSize: 10.sp,
                  //           fontWeight: FontWeight.bold,
                  //           color: _getLevelColor(),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: 4.h),

                  // /// Ô nhập "Có gì mới?"
                  GestureDetector(
                    onTap: onPost,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                     
                      child: Text(
                        "Bạn đang nghĩ gì?",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
