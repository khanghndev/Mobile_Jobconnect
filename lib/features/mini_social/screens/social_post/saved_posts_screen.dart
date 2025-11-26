import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_button_icon_simple.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_feed_shimmer.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/saved_post_card.dart';
import 'package:provider/provider.dart';

class SavedPostsScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final String? folderName;

  const SavedPostsScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    this.folderName,
  });

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final SocialSavePostViewModel _savePostVm;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _savePostVm = context.read<SocialSavePostViewModel>();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPosts() async {
    await _savePostVm.getSavedPosts();
    // Load full post details nếu chưa có
    // Note: API getSavedPostsByUser đã trả về post data trong SavedPostModel
    // Nếu cần load thêm, có thể gọi service trực tiếp
  }

  Future<void> _onRefresh() async {
    await _loadSavedPosts();
  }

  void _onOpenDetail(SocialPostModel post) {
    context.push(
      '/social/detail-post',
      extra: {
        'socialPostModel': post,
        'isLoggedIn': widget.isLoggedIn,
        'idUser': widget.idUser,
      },
    );
  }



  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppbarTitleLarge(
        title: widget.folderName ?? "Bài viết đã lưu",
      ),
      body: Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.savedPosts.isEmpty) {
            return SocialFeedShimmer();
          }

          if (vm.errorMessage != null && vm.savedPosts.isEmpty) {
            return BackgroundErrorState(
              title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
              onRetry: _loadSavedPosts,
            );
          }

          // Lọc các saved posts có post data
          var savedPostsWithData = vm.savedPosts
              .where((savedPost) => savedPost.post != null)
              .toList();

          // Nếu có folderName, filter theo folder
          if (widget.folderName != null) {
            savedPostsWithData = savedPostsWithData
                .where((savedPost) => savedPost.folderName == widget.folderName)
                .toList();
          }

          if (savedPostsWithData.isEmpty) {
            return BackgroundEmptyState(
              isSearching: false,
              onRefresh: _onRefresh,
              title: "Bài viết đã lưu",
              iconData: Icons.bookmark_border_rounded,
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 80,
            color: Colors.blue,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final savedPost = savedPostsWithData[index];
                        final post = savedPost.post!;
                        final isLast = index == savedPostsWithData.length - 1;
                        return Column(
                          children: [
                            SavedPostCard(
                              savedPost: savedPost,
                              post: post,
                              onTap: () => _onOpenDetail(post),
                            ),
                            if (isLast) ...[
                              SizedBox(height: 20.h),
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
                                  _onRefresh();
                                  _scrollToTop();
                                },
                                color: theme.primaryColor,
                                size: 24.sp,
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ],
                        );
                      },
                      childCount: savedPostsWithData.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _showFab
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onLongPress: _scrollToTop,
                onTap: _scrollToTop,
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

