  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/friend_status.dart';
  import 'package:provider/provider.dart';
  import 'package:job_connect/config/constant/app_images.dart';
  import 'package:job_connect/config/constant/app_strings.dart';
  import 'package:job_connect/config/utils/dialog_utils.dart';
  import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
  import 'package:job_connect/features/mini_social/model/social_post_model.dart';
  import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
  import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
  import 'package:job_connect/features/profile/view_model/user_view_model.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_actions.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_avatar.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_goals.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_header.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_stats.dart';
  import 'package:job_connect/features/mini_social/widgets/profile/profile_post_card.dart';
  import 'package:job_connect/config/widgets/unfocus_widget.dart';
  import 'package:job_connect/features/mini_social/widgets/shimmer/social_profile_shimmer.dart';

  class SocialProfileScreen extends StatefulWidget {
    final String idUser;
    const SocialProfileScreen({super.key, required this.idUser});

    @override
    State<SocialProfileScreen> createState() => _SocialProfileScreenState();
  }

  class _SocialProfileScreenState extends State<SocialProfileScreen> {
    bool _isLoadingFriendAction = false; // loading cho nút friend

    late UserViewModel userVm;
    late SocialPostViewModel socialPostVm;
    late SocialConnectionViewModel socialConnectionVm;

    @override
    void initState() {
      super.initState();
      userVm = context.read<UserViewModel>();
      socialPostVm = context.read<SocialPostViewModel>();
      socialConnectionVm = context.read<SocialConnectionViewModel>();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _onRefresh();
      });
    }

    Future<void> _onRefresh() async {
      userVm.getViewUser(widget.idUser);
      await socialPostVm.getPostsByUserId(widget.idUser);
      await socialConnectionVm.loadAllConnections(userId: widget.idUser);
    }

    /// Tính trạng thái bạn bè dựa vào ViewModel
    FriendStatus getFriendStatus() {
      final currentUserId = userVm.currentUser?.idUser;
      if (currentUserId == null) return FriendStatus.notFriend;

      if (socialConnectionVm.friends.any((f) => f.id == widget.idUser)) {
        return FriendStatus.friend;
      } else if (socialConnectionVm.sentRequests.any((r) => r.idUser2 == widget.idUser)) {
        return FriendStatus.requestSent;
      } else if (socialConnectionVm.requests.any((r) => r.idUser1 == widget.idUser)) {
        return FriendStatus.requestReceived;
      }
      return FriendStatus.notFriend;
    }

    /// Xử lý action bạn bè, update UI ngay lập tức
    Future<void> _handleFriendAction(FriendStatus action) async {
      final currentUser = userVm.currentUser;
      if (currentUser == null) return;

      setState(() => _isLoadingFriendAction = true);

      final request = SocialConnectionRequest(
        fromUserId: currentUser.idUser,
        toUserId: widget.idUser,
      );

      try {
        switch (action) {
          case FriendStatus.friend:
            await socialConnectionVm.unfriend(
                userId1: currentUser.idUser, userId2: widget.idUser);
            break;
          case FriendStatus.requestSent:
            await socialConnectionVm.cancelRequest(request: request);
            break;
          case FriendStatus.requestReceived:
            await socialConnectionVm.acceptRequest(request: request);
            break;
          case FriendStatus.notFriend:
            await socialConnectionVm.sendRequest(request: request);
            break;
        }
        // load lại connections để UI cập nhật ngay
        await socialConnectionVm.loadAllConnections(userId: widget.idUser);
        setState(() {}); // rebuild UI
      } finally {
        setState(() => _isLoadingFriendAction = false);
      }
    }

  // Tính tổng số lượt thích từ các posts của user
  int _calculateTotalLikes(List<SocialPostModel> posts) {
    return posts.fold<int>(0, (sum, post) => sum + post.likesCount);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().viewedUser;
    final posts = context.watch<SocialPostViewModel>()
        .posts
        .where((p) => p.idUser == widget.idUser)
        .toList();
    final totalLikes = _calculateTotalLikes(posts);
    final totalShared = context.watch<SocialPostViewModel>().totalShared;
    final totalFollows = context.watch<SocialPostViewModel>().totalFollows;
    final theme = Theme.of(context);

    if (userVm.isDetailLoading) return const SocialProfileShimmer();

    final isCurrentUser = userVm.currentUser?.idUser == user?.idUser;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: UnfocusWidget(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (_, __) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            ProfileHeader(
                              isCurrentUser: isCurrentUser,
                              isFriend: getFriendStatus() == FriendStatus.friend,
                              isLoading: _isLoadingFriendAction,
                              onBack: () => context.pop(),
                            ),
                            ProfileAMainAvatar(
                              imageUrl: user?.avatarUrl ?? AppImages.logoApp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              user?.userName ?? "Người dùng ${AppStrings.appName}",
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.h),
                            ProfileStats(followers: totalFollows, likes: totalLikes),
                            SizedBox(height: 24.h),
                            if (!isCurrentUser)
                              ProfileActions(
                                friendStatus: getFriendStatus(),
                                isLoading: _isLoadingFriendAction,
                                onMessagePressed: () {},
                                onAddFriend: () => _handleFriendAction(FriendStatus.notFriend),
                                onUnfriend: () => _handleFriendAction(FriendStatus.friend),
                                onAcceptRequest: () => _handleFriendAction(FriendStatus.requestReceived),
                                onCancelRequest: () => _handleFriendAction(FriendStatus.requestSent),
                              ),
                            SizedBox(height: 16.h),
                            ProfileGoals(
                              posts: posts.length,
                              likes: totalLikes,
                              shared: totalShared,
                              followers: totalFollows,
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [Tab(text: "Đã đăng"), Tab(text: "Video")],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      posts.isEmpty
                          ? Center(
                              child: Text(
                                "Chưa có bài viết",
                                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return ProfilePostCard(
                                  post: post,
                                  isCurrentUser: isCurrentUser,
                                  onTap: () {
                                    context.push(
                                      '/social/detail-post',
                                      extra: {
                                        'socialPostModel': post,
                                        'isLoggedIn': true,
                                        'idUser': userVm.currentUser?.idUser ?? '',
                                      },
                                    );
                                  },
                                  onEdit: () {
                                    context.push(
                                      '/social/edit-post',
                                      extra: {'socialPostModel': post},
                                    );
                                  },
                                  onDelete: () {
                                    DialogUtils.showConfirmationDialog(
                                      context: context,
                                      title: "Xóa bài viết",
                                      message: "Bạn muốn xóa bài viết này?",
                                      icon: Icons.delete_forever_rounded,
                                      onConfirm: () async {
                                        socialPostVm.deletePost(post.idPost);
                                        context.pop();
                                        await _onRefresh();
                                      },
                                    );
                                  },
                                  onViewDetail: () {
                                    context.push(
                                      '/social/detail-post',
                                      extra: {
                                        'socialPostModel': post,
                                        'isLoggedIn': true,
                                        'idUser': userVm.currentUser?.idUser ?? '',
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                      Center(
                        child: Text(
                          "Chưa có video",
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
    final TabBar tabBar;
    const _SliverAppBarDelegate(this.tabBar);

    @override
    double get minExtent => tabBar.preferredSize.height;
    @override
    double get maxExtent => tabBar.preferredSize.height;

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
      return Container(color: Colors.white, child: tabBar);
    }

    @override
    bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
  }
