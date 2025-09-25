import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/profile/posted_list.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_actions.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_avatar.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_goals.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_header.dart';
import 'package:job_connect/features/mini_social/widgets/profile/profile_stats.dart';
import 'package:job_connect/features/widgets/unfocus_widget.dart';

class DiscoverCardModel {
  final String title;
  final String imagePath;
  final String views;
  final String comments;
  final String likes;

  DiscoverCardModel({
    required this.title,
    required this.imagePath,
    required this.views,
    required this.comments,
    required this.likes,
  });
}
class SocialProfileScreen extends StatefulWidget {
  const SocialProfileScreen({super.key});

  @override
  State<SocialProfileScreen> createState() => _SocialProfileScreenState();
}

class _SocialProfileScreenState extends State<SocialProfileScreen> {
  bool _isExpanded = false;

  final List<DiscoverCardModel> discoverCards = List.generate(
    10, // số lượng phần tử muốn tạo
    (index) => DiscoverCardModel(
      title: "Discover CardDiscover CardDiscover Card ${index + 1}",
      imagePath: "assets/images/connect.png", // hoặc đổi tuỳ ý
      views: "${(index + 1) * 1000} views",
      comments: "${(index + 1) * 5}",
      likes: "${(index + 1) * 300}",
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF4FF),
      body: SafeArea(
        child: UnfocusWidget(
          child: RefreshIndicator(
            onRefresh: () async {},
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    const ProfileHeader(),
                    SizedBox(height: 12.h),
                    const ProfileAvatar(imageUrl: "https://i.pravatar.cc/150?img=12"),
                    SizedBox(height: 12.h),
                    Text(
                      "Kimberly",
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 16.h),
                    const ProfileStats(),
                    SizedBox(height: 24.h),
                    const ProfileActions(),
                    SizedBox(height: 24.h),
                    const ProfileGoals(),
                    SizedBox(height: 24.h),
                    DefaultTabController(
                      length: 3, // số tab
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
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
                            height: 420.h, 
                            child: TabBarView(
                              children: [
                                // Tab 1 - đã đăng
                                DiscoverList(
                                  cards: discoverCards,
                                  isExpanded: _isExpanded,
                                  onToggle: () => setState(() => _isExpanded = !_isExpanded),
                                ),
                                // Tab 2 - đã ẩn 
                                Center(
                                  child: Text(
                                    "Chưa có bài viết ẩn",
                                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                                  ),
                                ),
                                // Tab 3 - đã xóa
                                Center(
                                  child: Text(
                                    "Chưa có bài viết bị xóa",
                                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
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
