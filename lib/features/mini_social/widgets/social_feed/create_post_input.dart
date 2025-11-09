import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class UserInfoModel {
  final String avatarUrl;
  final String username;
  final String placeholder;

  UserInfoModel({
    required this.avatarUrl,
    required this.username,
    required this.placeholder,
  });
}

class CreatePostInput extends StatelessWidget {
  final UserInfoModel user;
  final VoidCallback? onCreatePost;
  final VoidCallback? onSearch;

  const CreatePostInput({
    super.key,
    required this.user,
    this.onCreatePost,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onCreatePost,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: ImageUtils.getImageProvider(user.avatarUrl),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.placeholder,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.search_rounded, color: Colors.grey, size: 22.sp),
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}
