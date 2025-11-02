import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_post_detail_shimmer.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_action_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item_header.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialPostDetailScreen extends StatefulWidget {
  final SocialPostModel socialPostModel;
  final bool isLiked;
  final bool isSaved;
  final String roleName;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final VoidCallback onShowReactions;
  final VoidCallback onFollow;
  final VoidCallback onHide;
  final VoidCallback onReport;
  final VoidCallback onCopyLink;
  final VoidCallback onOpenProfile;

  const SocialPostDetailScreen({
    super.key,
    required this.socialPostModel,
    required this.isLiked,
    required this.isSaved,
    required this.roleName,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onComment,
    required this.onShowReactions,
    required this.onFollow,
    required this.onHide,
    required this.onReport,
    required this.onCopyLink,
    required this.onOpenProfile,
  });

  @override
  State<SocialPostDetailScreen> createState() => _SocialPostDetailScreenState();
}

class _SocialPostDetailScreenState extends State<SocialPostDetailScreen> {
  late final SocialPostViewModel postVm;
  late final SocialCommentViewModel commentVm;
  late final UserViewModel userVm;
  final TextEditingController _commentController = TextEditingController();
  final Map<String, UserModel> _userCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    postVm = context.read<SocialPostViewModel>();
    commentVm = context.read<SocialCommentViewModel>();
    userVm = context.read<UserViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllData());
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await postVm.refreshPosts(roleName: widget.roleName);
    await commentVm.refreshComments(postId: widget.socialPostModel.idPost);

    // Load user info cho tất cả comments
    for (var c in commentVm.comments) {
      if (!_userCache.containsKey(c.idUser)) {
        final user = await userVm.fetchUserViewerById(c.idUser);
        _userCache[c.idUser] = user as UserModel;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onSubmitComment(String text, String? parentId) async {
    if (text.isEmpty) return;

    await commentVm.createComment(
      newComment: SocialCommentModel(
        idComment: '',
        idPost: widget.socialPostModel.idPost,
        idUser: widget.socialPostModel.idUser,
        content: text,
        parentComment: parentId,
        createdAt: DateTime.now(),
      ),
    );

    _commentController.clear();
    // Load user info mới cho comment vừa tạo
    await _loadUsersForComments(commentVm.comments);
  }

  Future<void> _loadUsersForComments(List<SocialCommentModel> comments) async {
    for (var c in comments) {
      if (!_userCache.containsKey(c.idUser)) {
        final user = await userVm.fetchUserViewerById(c.idUser);
        _userCache[c.idUser] = user as UserModel;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.backgroundDefaultPrimary,
      appBar: CustomAppbar(
        backgroundColor: BackgroundColors.backgroundDefaultPrimary,
        automaticallyImplyLeading: true,
        title: Text(
          'Bài viết của ${widget.socialPostModel.userName}',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: TextColors.textDefaultPrimary,
          ),
        ),
        leading: CustomAdaptiveTapEffect(
          isOpacity: true,
          onPressed: () => context.pop(),
          child: Icon(
            getAdaptiveBackIcon(context),
            size: 22.sp,
            color: IconColors.iconDefaultPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
            child: SocialPostDetailShimmer(
              isPostLoading: true,
              isCommentLoading: true,
            )
          )
          : RefreshIndicator(
              onRefresh: _loadAllData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostItemHeader(
                            socialPostModel: widget.socialPostModel,
                            roleName: widget.roleName,
                            onFollow: widget.onFollow,
                            onHide: widget.onHide,
                            onCopyLink: widget.onCopyLink,
                            onReport: widget.onReport,
                            onOpenProfile: widget.onOpenProfile,
                          ),
                          SizedBox(height: 8.h),
                          Html(
                            data: widget.socialPostModel.content,
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
                          SizedBox(height: 12.h),
                          PostActionBar(
                            likesCount: widget.socialPostModel.likesCount,
                            commentCount: widget.socialPostModel.commentsCount,
                            shareCount: widget.socialPostModel.sharesCount,
                            isLiked: widget.isLiked,
                            isSaved: widget.isSaved,
                            onLike: widget.onLike,
                            onSave: widget.onSave,
                            onShare: widget.onShare,
                            onComment: widget.onComment,
                            onShowReactions: widget.onShowReactions,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: CommentBottomSheet(
                        commentController: _commentController,
                        comments: commentVm.comments,
                        onSubmit: _onSubmitComment,
                        resolveUsername: (id) => _userCache[id]?.userName ?? "",
                        resolveUserAvatar: (id) => _userCache[id]?.avatarUrl ?? AppImages.defaultAvatar,
                        isDrag: false,
                        isScrollComment: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
