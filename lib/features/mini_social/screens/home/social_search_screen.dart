import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // package shimmer

import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_search_bar.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_search/search_user_item.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class SocialSearchScreen extends StatefulWidget {
  final String idUser;
  const SocialSearchScreen({super.key, required this.idUser});

  @override
  State<SocialSearchScreen> createState() => _SocialSearchScreenState();
}

class _SocialSearchScreenState extends State<SocialSearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  final List<String> _tabs = [
    "Tất cả",
    "Bạn bè",
    "Đã gửi",
    "Lời mời kết bạn",
  ];

  bool _isLoadingTab = false;
  final Set<int> _loadedTabs = {}; // Track các tab đã load
  bool _usersLoaded = false; // Track xem users đã load chưa

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTabData(_selectedTab, forceReload: false);
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTabData(int tabIndex, {bool forceReload = false}) async {
    final userVm = context.read<UserViewModel>();
    final connVm = context.read<SocialConnectionViewModel>();

    // Kiểm tra xem tab đã load chưa, nếu đã load và không force reload thì bỏ qua
    if (!forceReload && _loadedTabs.contains(tabIndex) && _usersLoaded) {
      return;
    }

    setState(() => _isLoadingTab = true);

    // Chỉ fetch user list nếu chưa load
    if (!_usersLoaded) {
      await userVm.fetchAllUsers();
      _usersLoaded = true;
    }

    // Load dữ liệu theo tab (chỉ load nếu chưa load hoặc force reload)
    if (!_loadedTabs.contains(tabIndex) || forceReload) {
      switch (tabIndex) {
        case 1:
          // Tab "Bạn bè" - chỉ load friends
          if (connVm.friends.isEmpty || forceReload) {
            await connVm.getFriends(userId: widget.idUser);
          }
          break;
        case 2:
          // Tab "Đã gửi" - chỉ load sent requests
          if (connVm.sentRequests.isEmpty || forceReload) {
            await connVm.getSentRequests(userId: widget.idUser);
          }
          break;
        case 3:
          // Tab "Lời mời kết bạn" - chỉ load requests
          if (connVm.requests.isEmpty || forceReload) {
            await connVm.getRequests(userId: widget.idUser);
          }
          break;
        default:
          // Tab "Tất cả" - load tất cả connections
          if (forceReload || 
              connVm.friends.isEmpty || 
              connVm.sentRequests.isEmpty || 
              connVm.requests.isEmpty) {
            await connVm.loadAllConnections(userId: widget.idUser);
          }
      }
      _loadedTabs.add(tabIndex);
    }

    if (!mounted) return;
    setState(() => _isLoadingTab = false);
  }

  List<UserModel> _getFilteredUsers(List<UserModel> allUsers, SocialConnectionViewModel connVm) {
    final keyword = _searchController.text.toLowerCase();

    List<UserModel> filtered = allUsers
        .where((u) => u.idUser != widget.idUser)
        .where((u) =>
            u.userName.toLowerCase().contains(keyword) ||
            u.email.toLowerCase().contains(keyword))
        .toList();

    switch (_selectedTab) {
      case 1:
        filtered = filtered
            .where((u) => connVm.friends.any((f) => f.id == u.idUser))
            .toList();
        break;
      case 2:
        filtered = filtered
            .where((u) => connVm.sentRequests.any((r) => r.idUser2 == u.idUser))
            .toList();
        break;
      case 3:
        filtered = filtered
            .where((u) => connVm.requests.any((r) => r.idUser1 == u.idUser))
            .toList();
        break;
    }

    return filtered;
  }

  Future<void> _sendFriendRequest(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();

    await connVm.sendRequest(
      request: SocialConnectionRequest(
        fromUserId: widget.idUser,
        toUserId: targetUser.idUser,
      ),
    );

    await connVm.getSentRequests(userId: widget.idUser);
  }

  Future<void> _unfriend(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.unfriend(userId1: widget.idUser, userId2: targetUser.idUser);

    // Refresh tab nếu đang ở tab "Bạn bè"
    await connVm.getFriends(userId: widget.idUser);
  }

  Future<void> _acceptRequest(UserModel user) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.acceptRequest(
      request: SocialConnectionRequest(
        fromUserId: widget.idUser,
        toUserId: user.idUser,
      ),
    );
    await connVm.getRequests(userId: widget.idUser); // cập nhật tab lời mời
    await connVm.getFriends(userId: widget.idUser);  // cập nhật bạn bè
  }

  Future<void> _rejectRequest(UserModel user) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.rejectRequest(
      request: SocialConnectionRequest(
        fromUserId:  widget.idUser,
        toUserId: user.idUser,
      ),
    );
    await _loadTabData(_selectedTab);
  }

  Future<void> _cancelFriendRequest(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();

    // Tạo request object
    final request = SocialConnectionRequest(
      fromUserId: widget.idUser,
      toUserId: targetUser.idUser,
    );

    await connVm.cancelRequest(request: request);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final userVm = context.watch<UserViewModel>();
    final connVm = context.watch<SocialConnectionViewModel>();
    final postVm = context.watch<SocialPostViewModel>();

    final filteredUsers = _getFilteredUsers(userVm.users, connVm);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: 'Tìm kiếm'),
      body: UnfocusWidget(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.h),
                child: CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm kiếm bạn bè',
                  borderRadius: 30.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildCustomTabBar(),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadTabData(_selectedTab, forceReload: true),
                  child: _isLoadingTab
                      ? _buildShimmerList()
                      : filteredUsers.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Center(
                                  child: BackgroundEmptyState(
                                    onRefresh: () => _loadTabData(_selectedTab, forceReload: true),
                                    title: 'Không tìm thấy người dùng',
                                    subTitle: 'Hiện tại chưa có thông tin người dùng.',
                                    iconData: Icons.supervised_user_circle_outlined,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                final isFriend = connVm.friends
                                    .any((f) => f.id == user.idUser);
                                final isSent = connVm.sentRequests
                                    .any((r) => r.idUser2 == user.idUser);
                                final isRequestReceived = connVm.requests
                                    .any((r) => r.idUser1 == user.idUser);

                                return SearchUserItem(
                                  avatar: user.avatarUrl ?? '',
                                  name: user.userName,
                                  postCount: '${postVm.getPostCountByUser(user.idUser)} bài viết',
                                  isFriend: isFriend,
                                  isRequestSent: isSent,
                                  isRequestReceived: isRequestReceived,
                                  onSendRequest: () => _sendFriendRequest(user),
                                  onUnfriend: () => _unfriend(user),
                                  onCancelRequest: () => _cancelFriendRequest(user), 
                                  onAcceptRequest: isRequestReceived
                                    ? () => _acceptRequest(user)
                                    : null,
                                  onRejectRequest: isRequestReceived
                                    ? () => _rejectRequest(user)
                                    : null,
                                  onOpenProfile: () {
                                    context.push(
                                      '/social/profile',
                                      extra: {'idUser': user.idUser}
                                     );
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 14.h, color: Colors.white),
                      SizedBox(height: 6.h),
                      Container(width: 100.w, height: 12.h, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = index);
                _loadTabData(index, forceReload: false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
