import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/profile/posted_list.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_actions.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_avatar.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_goals.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_header.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_stats.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/widgets/profile/social_profile_shimmer.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialProfileScreen extends StatefulWidget {
  final String idUser;
  const SocialProfileScreen({super.key, required this.idUser});

  @override
  State<SocialProfileScreen> createState() => _SocialProfileScreenState();
}

class _SocialProfileScreenState extends State<SocialProfileScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefresh();
    });
  }

  Future<void> _onRefresh() async {
    context.read<UserViewModel>().getViewUser(widget.idUser);
    await context.read<SocialPostViewModel>().getPostsByUserId(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    final userVm = context.watch<UserViewModel>();
    final socialPostVm = context.watch<SocialPostViewModel>();
    final user = userVm.viewedUser;
    final posts = socialPostVm.posts;
    final theme = Theme.of(context);

    if (userVm.isDetailLoading) {
      return const SocialProfileShimmer();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: UnfocusWidget(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    const ProfileHeader(),
                    SizedBox(height: 12.h),
                    ProfileAMainAvatar(
                      imageUrl: user?.avatarUrl ?? AppImages.logoApp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      user?.userName ?? "Người dùng ${AppStrings.appName}",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const ProfileStats(),
                    SizedBox(height: 24.h),
                    const ProfileActions(),
                    SizedBox(height: 24.h),
                    const ProfileGoals(),
                    SizedBox(height: 24.h),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: "Đã đăng"),
                              Tab(text: "Đã ẩn"),
                              Tab(text: "Đã xóa"),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                DiscoverList(
                                  socialPostModels: posts,
                                  isExpanded: _isExpanded,
                                  onToggle: () => setState(() => _isExpanded = !_isExpanded),
                                ),
                                Center(
                                  child: Text(
                                    "Chưa có bài viết ẩn",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Colors.grey),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "Chưa có bài viết bị xóa",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
