import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_button_icon_simple.dart';
import 'package:job_connect/config/widgets/reaction_picker.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_feed_shimmer.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/save_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/create_post_input.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';

class SocialFeedScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final VoidCallback onSearch;

  const SocialFeedScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.onSearch,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _showFab = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late final SocialPostViewModel socialPostVm;
  late final SocialCommentViewModel socialCommentVm;
  late final SocialSavePostViewModel socialSavePostVm;
  late final UserViewModel userVm;
  late final SocialConnectionViewModel socialConnectionVm;
  String selectedFolder = 'Bài viết yêu thích';
  
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    socialPostVm = context.read<SocialPostViewModel>();
    socialCommentVm = context.read<SocialCommentViewModel>();
    userVm = context.read<UserViewModel>();
    socialSavePostVm = context.read<SocialSavePostViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await userVm.loadRoleName();
      if (userVm.roleName != null) {
        await socialPostVm.getAllPosts();
      }
      if (widget.isLoggedIn && userVm.currentUser != null) {
        await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= 300 && _showFab) {
        setState(() => _showFab = false);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _commentController.dispose();

    _folderController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  void _onCreatePost() {
    context.push('/social/create-post');
  }

  void _onReport({required String userName, required String authorName}) {
    context.push(
      '/social/report',
      extra: {'userName': userName, 'authorName': authorName});
  }

  void _onGoToGroup(String idGroup) {
    context.push(
      '/social/group',
      extra: {
        'idGroup': idGroup,
        'isLoggedIn': widget.isLoggedIn,
        'idUser': widget.idUser,
      },
    );
  }

  void _onOpenDetail(SocialPostModel post) {
    final socialPostVm = context.read<SocialPostViewModel>();
    final userVm = context.read<UserViewModel>();

    context.push(
      '/social/detail-post',
      extra: {
        'socialPostModel': post,
        'onFollow': () {},
        'onHide': () => socialPostVm.onHidePost(post.idPost),
        'onCopyLink': () => _onCopyPostLink(post.idPost),
        'onReport': () => _onReport(
          authorName: post.userName ?? 'Người dùng ${AppStrings.appName}',
          userName: userVm.currentUser!.userName,
        ),
        'onOpenProfile': () => _onOpenProfile(post.idUser),
        'onDeletePost': () => socialPostVm.deletePost(post.idPost),
        'onEditPost': () => socialPostVm.updatePost(post),
        'isLiked': socialPostVm.isPostLiked(post.idPost),
        'isSaved': socialPostVm.isPostSaved(post.idPost),
        'roleName' : userVm.roleName,
        'onLike': () => socialPostVm.onToggleLike(post.idPost),
        'onSave': () => _onSavePost(context, post),
        'onShare': () => _onShowBottomSheet(
          postId: post.idPost,
          type: 'share',
          onShare: () => socialPostVm.onSharePost(post.idPost),
        ),
        'onComment': () => _onShowBottomSheet(
          postId: post.idPost,
          type: 'comment',
          onComment: () => socialPostVm.onCommentPost(post.idPost),
        ),
        'onShowReactions': () => _onShowReactions(),
        'onGoToGroup': () => _onGoToGroup(post.idGroup ?? ''),
      },
    );
  }

  Future<void> _onSavePost(BuildContext context, SocialPostModel socialPost) async {
    final folders = await socialSavePostVm.getSavedFolders();
    const defaultFolder = 'Bộ sưu tập yêu thích';
    final folderToSelect = folders.isNotEmpty ? folders.first : defaultFolder;
    _onShowBottomSheet(
      postId: socialPost.idPost,
      type: 'save',
      onSave: (String? selected) async {
        final folderName = selected ?? folderToSelect;
        await socialSavePostVm.toggleSavePostWithFolder(
          idPost: socialPost.idPost,
          selectedFolder: folderName,
        );
        if (socialSavePostVm.isSuccess && context.mounted) {
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: 'Đã lưu vào "$folderName"',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
          );
        }
        if (socialSavePostVm.errorMessage != null && context.mounted) {
          DialogUtils.showConfirmationDialog(
            context: context,
            title: "Thông báo",
            message: "Lưu bài viết thất bại: ${socialSavePostVm.errorMessage}",
            icon: Icons.delete_forever_rounded,
            onConfirm: () async {
              
            },
          );
        }
      },
    );
  }

  void _onOpenProfile(String idUser) {
    context.push('/social/profile', extra: {'idUser': idUser});
  }

  void onFirstPage() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _onCopyPostLink(String id) {
    final link = "https://jobconnect.app/post/$id";
    Clipboard.setData(ClipboardData(text: link));
    SnackbarApp.show(
      context,
      title: "Thành công",
      message: "Sao chép link thành công",
      backgroundColor: BackgroundColors.backgroundSuccessPrimary,
    );
  }

  Future<void> _showBottomSheetWrapper(Widget child) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(
          padding: EdgeInsets.all(8.w),
          child: child,
        ),
      ),
    );
  }

 Future<void> _showCommentSheet(String postId) async {
    // Load comment và user trước (dù chỉ mất 1–2 frame để rebuild)
    if (mounted) {
      socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm);
    }
    // Mở sheet ngay
    await _showBottomSheetWrapper(
      Consumer<SocialCommentViewModel>(
        builder: (context, vm, _) {
          return CommentBottomSheet(
            commentController: _commentController,
            comments: vm.comments,
            isLoading: vm.isLoading,
            errorMessage: vm.errorMessage,
            onSubmit: (text, parentId) async {
              if (text.isNotEmpty) {
                await vm.createComment(
                  newComment: SocialCommentModel(
                    idComment: '',
                    idPost: postId,
                    idUser: widget.idUser,
                    content: text,
                    parentComment: parentId,
                    createdAt: DateTime.now(),
                  ),
                );
                _commentController.clear();
              }
            },
            onRefresh: () => vm.loadCommentsWithUsers(postId: postId, userVm: userVm),
            resolveUsername: vm.resolveUsername,
            resolveUserAvatar: vm.resolveUserAvatar,
          );
        },
      ),
    );
  }

  Future<void> _showSaveSheet(String postId) async {
    // Sau khi BottomSheet mở, load dữ liệu
    if (mounted) {
      socialSavePostVm.loadSavedData(); 
    }
    // Mở sheet ngay với trạng thái loading
    await _showBottomSheetWrapper(
      Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) {
          return SaveBottomSheet(
            folderSavedCount: vm.folderSavedCount,
            folders: vm.folders,
            isLoading: vm.isLoading,
            errorMessage: vm.errorMessage,
            onSaved: (folderName) async {
              vm.setSelectedFolder(folderName);
              await vm.savePost(idPost: postId, folderName: folderName);
              vm.folderSavedCount[folderName] = (vm.folderSavedCount[folderName] ?? 0) + 1;

              if (vm.isSuccess && context.mounted) {
                context.pop();
                SnackbarApp.show(
                  context,
                  title: 'Thành công',
                  message: 'Lưu vào $folderName thành công',
                  backgroundColor: BackgroundColors.backgroundSuccessPrimary,
                );
              } else if (vm.errorMessage != null && context.mounted) {
                context.pop();
                SnackbarApp.show(
                  context,
                  title: 'Thất bại',
                  message: 'Lưu vào $folderName thất bại',
                  backgroundColor: BackgroundColors.backgroundErrorPrimary,
                );
              }
            },
            onDelete: (folder) async {},
            onCreateFolder: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: const Text('Tạo bộ sưu tập mới'),
                  content: TextField(
                    controller: _folderController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên bộ sưu tập',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _folderController.clear();
                        ctx.pop();
                      },
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _folderController.text.trim();
                        if (name.isNotEmpty) await vm.savePost(idPost: postId, folderName: name);
                        _folderController.clear();
                        if (ctx.mounted) ctx.pop();
                      },
                      child: const Text('Tạo'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showShareSheet(VoidCallback onShare) async {
    await _showBottomSheetWrapper(
      Consumer<SocialConnectionViewModel>(
        builder: (context, vm, _) => ShareBottomSheet(
          onShare: onShare,
          listFriend: vm.friends,
          isLoading: vm.isLoading,
        ),
      ),
    );
  }

  void _onShowBottomSheet({
    required String type,
    required String postId,
    VoidCallback? onShare,
    VoidCallback? onComment,
    Future<void> Function(String?)? onSave,
  }) {
    switch (type) {
      case 'comment':
        _showCommentSheet(postId);
        break;
      case 'save':
        _showSaveSheet(postId);
        break;
      case 'share':
        if (onShare != null) _showShareSheet(onShare);
        break;
    }
  }

  void _onShowReactions() async {
    await ReactionPicker.show(
      context,
      onSelected: (reaction) {
      
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Consumer<SocialPostViewModel>(
      builder: (context, socialPostVm, _) {
        if(socialPostVm.isLoading){
          return SocialFeedShimmer();
        }
        if(socialPostVm.errorMessage != null){
          return BackgroundErrorState(
            title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
            onRetry: () => socialPostVm.getPostsByRole(roleName: userVm.roleName!),
          );
        }
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => socialPostVm.refreshPosts(roleName: userVm.roleName!),
            displacement: 80,
            color: Colors.blue,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CreatePostInput(
                          user: UserInfoModel(
                            avatarUrl: userVm.currentUser?.avatarUrl ?? AppImages.logoApp,
                            username: userVm.currentUser?.userName ?? "Chưa có tên người dùng",
                            placeholder: 'Có gì mới?',
                          ),
                          onSearch: widget.onSearch,
                          onCreatePost: _onCreatePost,
                        ),
                      ),
                      Divider(height: 20.h),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = socialPostVm.posts[index];
                      final isLast = index == socialPostVm.posts.length - 1;
                      return Column(
                        children: [
                          Consumer<SocialSavePostViewModel>(
                            builder: (context, saveVm, _) {
                              return PostItem(
                                socialPostModel: post,
                                isLiked: socialPostVm.isPostLiked(post.idPost),
                                isSaved: post.isSaved,
                                idUser: socialPostVm.currentUserId,
                                roleName: userVm.roleName!,
                                isFollowedOrTaken: userVm.roleName!.toLowerCase() == UserRole.candidate.name ? true : false,
                                onFollow: () {
                                  if (userVm.roleName!.toLowerCase() == UserRole.recruiter.name) {
                                    //TODO: Theo dõi người dùng
                                    socialPostVm.onToggleFollow(post.idUser, false);
                                  } else if (userVm.roleName!.toLowerCase() == UserRole.candidate.name){
                                    //TODO: Nhận việc
                                    
                                  }
                                },
                                onDeletePost: () => socialPostVm.deletePost(post.idPost),
                                onEditPost: () => socialPostVm.updatePost(post),
                                onLike: () => socialPostVm.onToggleLike(post.idPost),
                                onSave: () => _onSavePost(context, post),
                                onShare: () => _onShowBottomSheet(
                                  postId: post.idPost,
                                  type: 'share',
                                  onShare: () => socialPostVm.onSharePost(post.idPost)
                                ),
                                onHide: () => socialPostVm.onHidePost(post.idPost),
                                onCopyLink: () => _onCopyPostLink(post.idPost),
                                onOpenDetail: () => _onOpenDetail(post),
                                onOpenProfile: () => _onOpenProfile(post.idUser),
                                onReport: () => _onReport(
                                  authorName: post.userName ?? 'Người dùng ${AppStrings.appName}',
                                  userName: userVm.currentUser!.userName,
                                ),
                                onComment: () => _onShowBottomSheet(
                                  postId: post.idPost,
                                  type: 'comment',
                                  onComment: () => socialPostVm.onCommentPost(post.idPost),
                                ),
                                onShowReactions: _onShowReactions,
                                onGoToGroup: () => _onGoToGroup(post.idGroup!),
                              );
                            }
                          ),
                          SizedBox(
                            height: 4.h,
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.borderSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          if (isLast) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(
                                title: "Bạn đã xem hết rồi",
                                textColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                isCenter: true,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(
                                title: "Hãy quay lại sau để xem những thông tin mới.",
                                textColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.25),
                                isCenter: true,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            CustomButtonIconSimple(
                              icon: Icons.refresh_rounded,
                              onTap: () {
                                socialPostVm.refreshPosts(roleName: userVm.roleName!);
                                onFirstPage();
                              },
                              color: theme.primaryColor,
                              size: 24.sp,
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ],
                      );
                    },
                    childCount: socialPostVm.posts.length,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _showFab
            ? ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onLongPress: onFirstPage,
                  onTap: !widget.isLoggedIn 
                    ? () => context.push(
                        '/auth/login', 
                        extra: {
                          'role': UserRole.candidate.name
                        }
                      )
                    : widget.onSearch,
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isLoggedIn ? Icons.search_rounded : Icons.login,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              )
            : null,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}