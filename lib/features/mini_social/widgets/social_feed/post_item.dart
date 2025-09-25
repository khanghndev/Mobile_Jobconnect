import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/screens/social_post_detail_screen.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_action_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item_header.dart';

class PostModel {
  final String postId;
  final String avatarUrl;
  final String username;
  final String group;
  final String timeAgo;
  final String content;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  PostModel({
    required this.postId,
    required this.avatarUrl,
    required this.username,
    required this.group,
    required this.timeAgo,
    required this.content,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
  });
}

class PostItem extends StatelessWidget {
  final PostModel post;
  final VoidCallback onFolow;

  const PostItem({
    super.key, 
    required this.post, 
    required this.onFolow
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Header: Avatar + Info + Follow
          PostItemHeader(
            postId: post.postId,
            avatarUrl: post.avatarUrl,
            username: post.username,
            group: post.group,
            timeAgo: post.timeAgo,
            onFollow: onFolow
          ),

          SizedBox(height: 12.h),

          // Content
          InkWell(
            splashColor: Colors.transparent, 
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: post),
                ),
              );
            },
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),

          SizedBox(height: 12.h),

          // Action Bar
          PostActionBar(
            reactionCount: post.likeCount,
            commentCount: post.commentCount,
            shareCount: post.shareCount,
          ),

          Container(
            height: 4.h,
            color: Colors.grey[300],
          )
        ],
      ),
    );
  }
}
