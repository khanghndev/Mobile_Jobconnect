import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/file_utils.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ChatMessageItem extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final bool showDetails;
  final String avatarUrl;
  final String idUser;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onOpenProfile;

  const ChatMessageItem({
    super.key,
    required this.msg,
    required this.isMe,
    required this.showDetails,
    required this.avatarUrl,
    required this.idUser,
    required this.onTap,
    required this.onOpenProfile,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final postVm = context.watch<SocialPostViewModel>();
    final groupVm = context.watch<SocialGroupsViewModel>();
    SocialPostModel? post;
    SocialGroupsModel? group;
    if (msg.messageType == MessengerType.text.name) {
      group = groupVm.allGroups.firstWhereOrNull((g) => g.idGroup == msg.content);
      post = postVm.posts.firstWhereOrNull((p) => p.idPost == msg.content);
    }

    Widget messageContent() {
      if (post != null) return _buildPostCard(context, post);
      if (group != null) return _buildGroupCard(context, group);
      switch (msg.messageType) {
        case 'text':
        // Kiểm tra xem có HTML không
        final isHtml = msg.content.contains(RegExp(r"<[^>]+>"));
        if (isHtml) {
          return Html(
            data: msg.content,
            style: {
              "body": Style(
                fontSize: FontSize(14.sp),
                color: isMe ? Colors.white : Colors.black87,
              ),
            },
          );
        } else {
          return Text(
            msg.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 14.sp,
            ),
          );
        }
        case 'image':
          return GestureDetector(
            onLongPress: () => DialogUtils.showImageViewer(
              context,
              [msg.fileUrl ?? AppImages.notImage],
              0,
              canDelete: false,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                msg.fileUrl ?? AppImages.notImage,
                width: 200.w,
                fit: BoxFit.cover,
              ),
            ),
          );
        case 'file':
          return _buildFileWidget(context);
        default:
          return Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87));
      }
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showDetails)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    DateUtilsHelper.formatDateTime(msg.sentAt),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  GestureDetector(
                    onTap: onOpenProfile,
                    child: CircleAvatar(radius: 18.r, backgroundImage: ImageUtils.getImageProvider(avatarUrl)),
                  ),
                if (!isMe) SizedBox(width: 8.w),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: msg.messageType == 'text' && post == null && group == null
                          ? (isMe ? Colors.lightBlue : Colors.grey[200])
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: messageContent(),
                  ),
                ),
              ],
            ),
            if (showDetails)
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: isMe ? 0 : 46.w, right: isMe ? 46.w : 0),
                child: Text(
                  isMe
                      ? (msg.isRead
                          ? "Đã xem • ${DateUtilsHelper.timeAgo(msg.sentAt)} trước"
                          : "Đã gửi • ${DateUtilsHelper.timeAgo(msg.sentAt)} trước")
                      : "Đã xem • ${DateUtilsHelper.timeAgo(msg.sentAt)} trước",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileWidget(BuildContext context) {
    final fileName = msg.fileName ?? "";
    final fileUrl = msg.fileUrl ?? "";
    final icon = getFileIcon(fileName);
    final bgColor = getFileBgColor(fileName, context);
    final iconColor = getFileIconColor(fileName, context);

    return Container(
      padding: EdgeInsets.all(12.w),
      constraints: BoxConstraints(maxWidth: 240.w, minWidth: 160.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues( alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () => context.push('/resume/file', extra: {'fileUrl': fileUrl, 'fileName': fileName}),
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, size: 22.sp, color: iconColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.sd_storage_outlined, size: 12.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        msg.fileSize != null ? "${msg.fileSize} KB" : "Không rõ dung lượng",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, SocialPostModel post) {
    return GestureDetector(
      onTap: () {
        context.push(
        '/social/detail-post',
          extra: {
            'socialPostModel': post,
            'isLoggedIn': true, 
            'idUser': idUser,
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16.r, backgroundImage: ImageUtils.getImageProvider(post.avatarUrl)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName ?? 'Người dùng',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      SizedBox(height: 2.h),
                      Text(DateUtilsHelper.timeAgo(post.createdAt),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (post.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Html(
                  data: post.content,
                  style: {"body": Style(fontSize: FontSize(14.sp), color: Colors.black87)},
                ),
              ),
            if (post.imageUrl != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(post.imageUrl!, width: double.infinity, height: 120.h, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, SocialGroupsModel group) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.push(
          '/social/group',
          extra: {
            'idGroup': group.idGroup,
            'idUser': idUser,
            'isLoggedIn': true,
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh nhóm
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image(
                image: ImageUtils.getImageProvider(group.avatarUrl),
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.h),

            // Tên nhóm
            Text(
              group.groupName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),

            // Privacy + creator
            Row(
              children: [
                Icon(
                  group.privacy.toLowerCase() == 'public' ? Icons.public : Icons.lock,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  group.privacy.toLowerCase() == 'public' ? 'Công khai' : 'Riêng tư',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Người tạo: ${group.creatorName}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Member count + post count
            Row(
              children: [
                Icon(Icons.group, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  '${group.memberCount} thành viên',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.post_add, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  '${group.postCount} bài viết',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
