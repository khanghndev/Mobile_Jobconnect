import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class ProfilePostCard extends StatelessWidget {
  final SocialPostModel post;
  final bool isCurrentUser;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetail;

  const ProfilePostCard({
    super.key,
    required this.post,
    required this.isCurrentUser,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewDetail,
  });

  String _getContentPreview(String content) {
    // Loại bỏ HTML tags và lấy preview
    final plainText = content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .trim();
    
    if (plainText.length <= 100) {
      return plainText;
    }
    return '${plainText.substring(0, 100)}...';
  }

  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final k = (number / 1000).toStringAsFixed(1);
      return '${k.replaceAll(RegExp(r'\.0$'), '')}K';
    } else {
      final m = (number / 1000000).toStringAsFixed(1);
      return '${m.replaceAll(RegExp(r'\.0$'), '')}M';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrls != null && post.imageUrls!.isNotEmpty;
    final firstImage = hasImage ? post.imageUrls!.first : null;
    final contentPreview = _getContentPreview(post.content);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Time, More button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.network(
                      post.avatarUrl ?? AppImages.defaultAvatar,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        AppImages.defaultAvatar,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Người dùng',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          DateUtilsHelper.timeAgo(post.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More button với PopupMenuButton
                  if (isCurrentUser)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20.sp,
                        color: Colors.grey[700],
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                          case 'view':
                            onViewDetail?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_rounded, size: 18.sp, color: Colors.grey[700]),
                              SizedBox(width: 8.w),
                              Text('Xem bài viết', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18.sp, color: Colors.grey[700]),
                              SizedBox(width: 8.w),
                              Text('Sửa bài viết', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 18.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text('Xóa bài viết', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Content preview
            if (contentPreview.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  contentPreview,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Image preview
            if (firstImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      firstImage,
                      width: double.infinity,
                      height: 200.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 200.h,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    // Image count badge nếu có nhiều ảnh
                    if (post.imageUrls != null && post.imageUrls!.length > 1)
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${post.imageUrls!.length}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Footer: Stats
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Like count
                  _buildStatItem(
                    icon: Icons.favorite_rounded,
                    count: post.likesCount,
                    color: Colors.red[400]!,
                  ),
                  SizedBox(width: 20.w),
                  // Comment count
                  _buildStatItem(
                    icon: Icons.comment_rounded,
                    count: post.commentsCount,
                    color: Colors.blue[400]!,
                  ),
                  SizedBox(width: 20.w),
                  // Share count
                  _buildStatItem(
                    icon: Icons.share_rounded,
                    count: post.sharesCount,
                    color: Colors.green[400]!,
                  ),
                  const Spacer(),
                  // Post type badge
                  if (post.postType != null && post.postType != 'post')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getPostTypeColor(post.postType!).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _getPostTypeLabel(post.postType!),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getPostTypeColor(post.postType!),
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

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          _formatNumber(count),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getPostTypeColor(String postType) {
    switch (postType.toLowerCase()) {
      case 'job':
        return Colors.orange;
      case 'qa':
        return Colors.blue;
      case 'microjob':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getPostTypeLabel(String postType) {
    switch (postType.toLowerCase()) {
      case 'job':
        return 'Việc làm';
      case 'qa':
        return 'Hỏi đáp';
      case 'microjob':
        return 'Việc ngắn hạn';
      default:
        return postType;
    }
  }
}

