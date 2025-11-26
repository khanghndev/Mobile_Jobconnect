import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class PostItemHeader extends StatelessWidget {
  final SocialPostModel socialPostModel;
  final VoidCallback? onFollow;
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
  final VoidCallback? onOpenDetail;

  const PostItemHeader({
    super.key,
    required this.socialPostModel,
    this.onFollow,
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
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Quyền xóa/sửa: chủ bài viết hoặc chủ nhóm
    final bool isAuthor = idUser == socialPostModel.idUser;
    final bool isGroupOwner = socialPostModel.idGroup != null && socialPostModel.idUser == idUser;
    final bool canDelete = isAuthor || isGroupOwner;
    final bool canEdit = isAuthor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        GestureDetector(
          onTap: onOpenProfile,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: ImageUtils.getImageProvider(socialPostModel.avatarUrl),
          ),
        ),
        SizedBox(width: 12.w),

        // Username + Group
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Username - không cắt, hiển thị đầy đủ trên 1 dòng
                  Flexible(
                    child: GestureDetector(
                      onTap: onOpenProfile,
                      child: Text(
                        socialPostModel.userName ?? 'Người dùng',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),

                  // Nếu có group
                  if (socialPostModel.groupName != null && socialPostModel.groupName!.isNotEmpty) ...[
                    SizedBox(width: 48.w),
                    Icon(
                      Icons.arrow_right,
                      color: theme.iconTheme.color,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    // Group name - chỉ cắt nếu dài quá
                    Flexible(
                      child: GestureDetector(
                        onTap: onGoToGroup,
                        child: Text(
                          socialPostModel.groupName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2.h),

              // Thời gian + Visibility
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      DateUtilsHelper.timeAgo(socialPostModel.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    socialPostModel.visibility == 'public' ? Icons.public : Icons.lock,
                    size: 16.sp,
                    color: theme.iconTheme.color?.withValues( alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Khoảng trống touch area
        GestureDetector(
          onTap: onOpenDetail ?? () {},
          child: Container(
            color: Colors.transparent,
            height: 30.h,
            width: 30.w,
          ),
        ),

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
            itemBuilder: (context) {
              List<PopupMenuEntry<int>> items = [];

              // Báo cáo
              items.add(PopupMenuItem(
                value: 1,
                child: Text(
                  "Báo cáo bài viết",
                  style: theme.textTheme.bodyMedium,
                ),
              ));

              // Ẩn bài viết
              items.add(PopupMenuItem(
                value: 2,
                child: Text(
                  "Ẩn bài viết",
                  style: theme.textTheme.bodyMedium,
                ),
              ));

              // Chỉnh sửa bài viết (chỉ tác giả)
              if (canEdit) {
                items.add(PopupMenuItem(
                  value: 3,
                  child: Text(
                    "Chỉnh sửa bài viết",
                    style: theme.textTheme.bodyMedium,
                  ),
                ));
              }

              // Xóa bài viết (tác giả hoặc chủ nhóm)
              if (canDelete) {
                items.add(PopupMenuItem(
                  value: 4,
                  child: Text(
                    "Xóa bài viết",
                    style: theme.textTheme.bodyMedium,
                  ),
                ));
              }

              // Sao chép link
              items.add(PopupMenuItem(
                value: 5,
                child: Text(
                  "Sao chép link bài viết",
                  style: theme.textTheme.bodyMedium,
                ),
              ));

              return items;
            },
          ),
        ),
      ],
    );
  }
}
