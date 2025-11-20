import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/action_button.dart';

class PostActionBar extends StatelessWidget {
  final int likesCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked; 
  final bool isSaved;
  final bool isAccessJob;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onComment;
  final VoidCallback? onAccessJob;

  const PostActionBar({
    super.key,
    required this.likesCount,
    required this.commentCount,
    required this.shareCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isAccessJob = false,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    this.onComment,
    this.onAccessJob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Row(
                children: [
                  if(likesCount > 0)...[
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 20.sp,
                      color: Colors.pinkAccent
                    )
                  ],
                  SizedBox(width: 4.w),
                  Text(
                    '$likesCount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                '$commentCount bình luận',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$shareCount lượt chia sẻ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ActionButton(
                icon: isLiked ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                label: isLiked ? "Đã thích" : "Thích",
                onTap: onLike,
                active: isLiked,
              ),
              ActionButton(
                icon: Icons.chat_bubble_outline,
                label: "Bình luận",
                onTap: onComment ?? (){},
              ),
              ActionButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
                label: isSaved ? "Đã lưu" : "Lưu",
                onTap: onSave,
                active: isSaved,
              ),
              ActionButton(
                icon: Icons.share_outlined,
                label: "Chia sẻ",
                onTap: onShare,
              ),
              if(isAccessJob)...[
                ActionButton(
                  icon: Icons.check_circle_outlined,
                  label: "Nhận việc",
                  onTap: onAccessJob ?? (){},
                ),
              ]
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}