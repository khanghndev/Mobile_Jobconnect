import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class PostItemHeader extends StatelessWidget {
  final SocialPostModel socialPostModel;
  final VoidCallback onFollow;
  final VoidCallback onHide;
  final VoidCallback onReport;
  final VoidCallback onCopyLink;
  final VoidCallback onOpenProfile;
  final String roleName;
  final bool isFollowedOrTaken;

  const PostItemHeader({
    super.key,
    required this.socialPostModel,
    required this.onFollow,
    required this.onHide,
    required this.onReport,
    required this.onCopyLink,
    required this.onOpenProfile,
    required this.roleName,
    this.isFollowedOrTaken = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = socialPostModel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onOpenProfile,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: ImageUtils.getImageProvider(post.avatarUrl),
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
                        post.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (post.groupName != null && post.groupName!.isNotEmpty) ...[
                    Icon(
                      Icons.arrow_right,
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => context.push('/social/group'),
                        child: Text(
                          post.groupName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
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
              Text(
                DateUtilsHelper.getTimeAgo(post.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 13.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Nút follow / nhận việc
        TextButton(
          onPressed: onFollow,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: isFollowedOrTaken ? Colors.grey : Colors.blue,
            side: BorderSide(color: isFollowedOrTaken ? Colors.grey : Colors.blue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            roleName.toLowerCase() == UserRole.recruiter.name
                ? (isFollowedOrTaken ? "Đang theo dõi" : "Theo dõi")
                : (isFollowedOrTaken ? "Đã nhận việc" : "Nhận việc"),
            style: theme.textTheme.labelSmall?.copyWith(
                color: isFollowedOrTaken ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.w600),
          ),
        ),
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
                  onFollow(); 
                  break;
                case 3:
                  onHide();
                  break;
                case 4:
                  onCopyLink();
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 1, child: Text("Báo cáo bài viết")),
              PopupMenuItem(value: 2, child: Text("Theo dõi / Nhận việc")),
              PopupMenuItem(value: 3, child: Text("Ẩn bài viết")),
              PopupMenuItem(value: 4, child: Text("Sao chép link bài viết")),
            ],
          ),
        ),
      ],
    );
  }
}