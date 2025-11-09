import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class UserInfoCreatePost extends StatelessWidget {
  final UserModel? user;
  final String roleName;
  final String? groupName;
  final bool isPublic;
  final String? userRoleName;
  final IconData? iconRole;

  const UserInfoCreatePost({
    super.key, 
    required this.user,
    required this.roleName,
    this.groupName, 
    this.isPublic = true, 
    this.userRoleName,
    this.iconRole
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundImage: ImageUtils.getImageProvider(user?.avatarUrl ?? ''),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          user?.userName ?? "Người dùng ${AppStrings.appName}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        if (groupName != null) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_right, size: 16.sp, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            groupName!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    iconRole ?? (roleName.toLowerCase() == UserRole.candidate.name
                      ? Icons.verified_user
                      : Icons.verified
                    ),
                    color: Colors.blue,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    (userRoleName ?? (roleName.toLowerCase() == UserRole.candidate.name
                      ? "Ứng viên"
                      : "Nhà tuyển dụng"
                    )),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    isPublic == true 
                      ? Icons.public 
                      : Icons.lock,
                    size: 16.sp,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}