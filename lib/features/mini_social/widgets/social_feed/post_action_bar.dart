import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/action_button.dart';

class PostActionBar extends StatelessWidget {
  final int likesCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked; 
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onComment;
  final VoidCallback onShowReactions;

  const PostActionBar({
    super.key,
    required this.likesCount,
    required this.commentCount,
    required this.shareCount,
    this.isLiked = false,
    this.isSaved = false,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    this.onComment,
    required this.onShowReactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Row(
                children: [
                  if(likesCount > 0)...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(left: 30, child: Text('😢', style: TextStyle(fontSize: 18.sp))),
                        Positioned(left: 14, child: Text('😍', style: TextStyle(fontSize: 18.sp))),
                        Positioned(child: Text('😂', style: TextStyle(fontSize: 18.sp))),
                      ],
                    ),
                  ],
                  SizedBox(width: 40.w),
                  Text(
                    '$likesCount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text('$commentCount bình luận', style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 8.w),
              Text('$shareCount lượt chia sẻ', style: TextStyle(fontSize: 14.sp)),
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
                icon: isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                label: isLiked ? "Đã thích" : "Thích",
                onTap: onLike,
                onLongPress: onShowReactions,
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
                icon: Icons.reply_outlined,
                label: "Chia sẻ",
                onTap: onShare,
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}