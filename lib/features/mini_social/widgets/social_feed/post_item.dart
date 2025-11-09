import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_action_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_image_grid.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item_header.dart';

class PostItem extends StatelessWidget {
  final SocialPostModel socialPostModel;
  final bool isLiked;
  final bool isSaved;
  final String roleName;
  final String idUser;
  final bool isFollowedOrTaken;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onHide;
  final VoidCallback onCopyLink;
  final VoidCallback onReport;
  final VoidCallback onDeletePost;
  final VoidCallback onEditPost;
  final VoidCallback onOpenDetail;
  final VoidCallback onOpenProfile;
  final VoidCallback onComment;
  final VoidCallback onShowReactions;
  final VoidCallback onGoToGroup;

  const PostItem({
    super.key,
    required this.socialPostModel,
    required this.isLiked,
    required this.isSaved,
    required this.roleName,
    required this.idUser,
    required this.isFollowedOrTaken,
    required this.onFollow,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onHide,
    required this.onCopyLink,
    required this.onReport,
    required this.onDeletePost,
    required this.onEditPost,
    required this.onOpenDetail,
    required this.onOpenProfile,
    required this.onComment,
    required this.onShowReactions,
    required this.onGoToGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Header: Avatar + Info + Theo dõi / Nhận việc
          PostItemHeader(
            socialPostModel: socialPostModel,
            roleName: roleName,
            idUser: idUser,
            isFollowedOrTaken: isFollowedOrTaken,
            onFollow: onFollow,
            onHide: onHide,
            onCopyLink: onCopyLink,
            onReport: onReport,
            onDeletePost: onDeletePost,
            onEditPost: onEditPost,
            onOpenProfile: onOpenProfile,
            onGoToGroup: onGoToGroup,
          ),

          SizedBox(height: 8.h),

          // Nội dung bài viết
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: onOpenDetail,
            child: Html(
              data: socialPostModel.content,
              style: {
                "body": Style(
                  fontSize: FontSize(14),
                  lineHeight: LineHeight.number(1.5),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: Colors.black87,
                ),
              },
            ),
          ),

          if (socialPostModel.imageUrls != null)...[
            GestureDetector(
              onTap: () => DialogUtils.showImageViewer(context, socialPostModel.imageUrls!, 0),
              child: PostImageGrid(
                imagePaths: socialPostModel.imageUrls!,
                isNetwork: true, 
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Action Bar: like, save, share, comment, reactions
          PostActionBar(
            likesCount: socialPostModel.likesCount,
            commentCount: socialPostModel.commentsCount,
            shareCount: socialPostModel.sharesCount,
            isLiked: isLiked,
            isSaved: isSaved,
            onLike: onLike,
            onSave: onSave,
            onShare: onShare,
            onComment: onComment,
            onShowReactions: onShowReactions,
          ),
        ],
      ),
    );
  }
}