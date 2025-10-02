import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/mini_social/screens/post/social_create_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_search_screen.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/stories.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/create_post_input.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';

// Model fake
class Story {
  final String imageUrl;
  final String name;
  final bool isDraft;

  Story({required this.imageUrl, required this.name, this.isDraft = false});
}

class SocialFeedScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const SocialFeedScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  bool _showFab = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Fake dữ liệu story
  final List<Story> stories = [
    Story(
      imageUrl: AppImages.logo,
      name: 'Tạo tin',
      isDraft: true,
    ),
    Story(
      imageUrl: AppImages.logo,
      name: 'Phùng Thanh Thảo',
    ),
    Story(
      imageUrl: AppImages.logo,
      name: 'Nhi Phương',
    ),
    Story(
      imageUrl: AppImages.logo,
      name: 'Anh Khoa',
    ),
    Story(
      imageUrl: AppImages.logo,
      name: 'Anh Khoa',
    ),
    Story(
      imageUrl: AppImages.logo,
      name: 'Anh Khoa',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void onCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatePostScreen()),
    );
  }

  void onFolow() {
    //TODO: Xử lí khi nhấn follow
  }

  void _refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshPage();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        displacement: 80,
        color: Colors.blue,
        backgroundColor: Colors.white,
        notificationPredicate: (notification) => true,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: CreatePostInput(
                      user: UserInfoModel(
                        avatarUrl: 'https://i.imgur.com/BoN9kdC.png',
                        username: 'nim.neit',
                        placeholder: 'Có gì mới?',
                      ),
                      onSearch: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => SocialSearchScreen())
                        );
                      },
                      onCreatePost: onCreatePost,
                    ),
                  ),
                  Divider(height: 20.h),
                  SizedBox(height: 8.h),
                  Stories(stories: stories),
                  SizedBox(height: 8.h),
                  Divider(height: 40.h),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: [
                      PostItem(
                        post: PostModel(
                          postId: index.toString(),
                          avatarUrl: 'https://i.imgur.com/BoN9kdC.png',
                          username: 'ngtrpm',
                          group: 'Intern Jobs',
                          timeAgo: '1 ngày',
                          content:
                              'Cả đoàn dắt tay nhau apply Intern tại Edufit dùm em nha\n\n'
                              '✨ Thực Tập Sinh Vận Hành CNTT\n'
                              '✨ Thực Tập Sinh Business Analyst (BA)\n'
                              '✨ Thực Tập Sinh Lập Trình (Dev)\n'
                              '✨ Thực Tập Sinh Thiết Kế UI/UX\n\n'
                              '🕒 offline từ 3 buổi/tuần trở lên\n📍 Starlake, Tây Hồ Tây\n\n'
                              'Dịp đặc biệt chỉ 1 lần trong năm thôiii, apply nhanh kẻo bỏ lỡ !\n📩 tuyendung@edufit.vn',
                          likeCount: 70,
                          commentCount: 9,
                          shareCount: 41,
                        ),
                        onFolow: onFolow,
                      ),
                      SizedBox(
                        height: 4.h,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: BorderColors.borderSeparatorOpaque.withValues(alpha: 0.2)
                          ),
                        )
                      )
                    ],
                  );
                },
                childCount: 10,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showFab
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onLongPress: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  );
                },
                onTap: () {
                  context.push(
                    '/search',
                    extra: {
                      'isLoggedIn': widget.isLoggedIn,
                      'idUser': widget.idUser,
                    },
                  );
                },
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
                    widget.isLoggedIn ? Icons.search_rounded : Icons.login,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
