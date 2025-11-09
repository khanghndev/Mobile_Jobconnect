import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class PostItemHeader extends StatelessWidget {
  final SocialPostModel socialPostModel;
  final VoidCallback onFollow;
  final VoidCallback onHide;
  final VoidCallback onReport;
  final VoidCallback onCopyLink;
  final VoidCallback onDeletePost;
  final VoidCallback onEditPost;
  final VoidCallback onOpenProfile;
  final String roleName;
  final bool isFollowedOrTaken;
  final String idUser;
  final VoidCallback onGoToGroup;

  const PostItemHeader({
    super.key,
    required this.socialPostModel,
    required this.onFollow,
    required this.onHide,
    required this.onReport,
    required this.onCopyLink,
    required this.onDeletePost,
    required this.onEditPost,
    required this.onOpenProfile,
    required this.roleName,
    this.isFollowedOrTaken = false,
    required this.idUser,
    required this.onGoToGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onOpenProfile,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: ImageUtils.getImageProvider(socialPostModel.avatarUrl),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () => context.push('/social/profile'),
                      child: Text(
                        socialPostModel.userName ?? 'Người dùng ${AppStrings.appName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (socialPostModel.groupName != null && socialPostModel.groupName!.isNotEmpty) ...[
                    Icon(
                      Icons.arrow_right,
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: onGoToGroup,
                        child: Text(
                          socialPostModel.groupName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    DateUtilsHelper.timeAgo(socialPostModel.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith
                    ( fontSize: 13.sp, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    socialPostModel.visibility == 'public' 
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
        SizedBox(width: 8.w),
        // Nút follow / nhận việc
        // TextButton(
        //   onPressed: onFollow,
        //   style: TextButton.styleFrom(
        //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        //     minimumSize: Size.zero,
        //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     foregroundColor: isFollowedOrTaken ? Colors.blue : Colors.grey,
        //     side: BorderSide(color: isFollowedOrTaken ? Colors.blue : Colors.grey),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        //   ),
        //   child: Text(
        //     roleName.toLowerCase() == UserRole.recruiter.name
        //       ? (isFollowedOrTaken ? "Theo dõi" : "Đang theo dõi" )
        //       : (isFollowedOrTaken ? "Nhận việc" : "Đã nhận việc"),
        //     style: theme.textTheme.labelSmall?.copyWith(
        //       color: isFollowedOrTaken ? Colors.blue : Colors.grey,
        //       fontWeight: FontWeight.w600
        //     ),
        //   ),
        // ),
        SizedBox(width: 8.w),
        // Popup menu
        SizedBox(
          height: 28.h,
          child: PopupMenuButton<int>(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_horiz,
              size: 22.sp,
              color: theme.iconTheme.color,
            ),
            onSelected: (value) {
              switch (value) {
                case 1:
                  onReport();
                  break;
                case 2:
                  onHide(); 
                  break;
                case 3:
                  onEditPost();
                  break;
                case 4:
                  onDeletePost();
                  break;
                case 5:
                  onCopyLink();
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 1, child: Text("Báo cáo bài viết")),
              PopupMenuItem(value: 2, child: Text("Ẩn bài viết")),
              if(idUser == socialPostModel.idUser)...[
                PopupMenuItem(value: 3, child: Text("Chỉnh sửa bài viết")),
                PopupMenuItem(value: 4, child: Text("Xóa bài viết")),
              ],
              PopupMenuItem(value: 5, child: Text("Sao chép link bài viết")),
            ],
          ),
        ),
      ],
    );
  }
}