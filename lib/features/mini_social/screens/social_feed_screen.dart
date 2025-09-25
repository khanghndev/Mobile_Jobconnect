import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/features/mini_social/screens/social_create_post_screen.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/job_board_list.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/create_post_input.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';

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

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin {
  bool _showFab = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
    void initState() {
      super.initState();
      _scrollController.addListener(() {
        if (_scrollController.offset > 300 && !_showFab) {
          setState(() => _showFab = true);
        } else if (_scrollController.offset <= 300 && _showFab) {
          setState(() => _showFab = false);
        }
      }
    );
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

  void onCreatePost(){
    //TODO: Chuyển sang trang tạo bài
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => CreatePostScreen())
    );
  }

  void onFolow(){
    //TODO: Xử lí khi nhấn follow - Lưu người theo dõi vào csdl - mất nút theo dõi trên post

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
                      onCreatePost: onCreatePost,
                    ),
                  ),
                  const Divider(height: 20),
                  SizedBox(height: 8.h),
                  StoriesWidget(),
                  SizedBox(height: 8.h),
                  const Divider(height: 40),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return PostItem(
                    post: PostModel(
                      postId: index.toString(),
                      avatarUrl: 'https://i.imgur.com/BoN9kdC.png',
                      username: 'ngtrpm',
                      group: 'Intern Jobs',
                      timeAgo: '1 ngày',
                      content: 'Cả đoàn dắt tay nhau apply Intern tại Edufit dùm em nha\n\n'
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
            onLongPress: (){
              // Cuộn lên đầu
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              );
            },
            onTap: () {
              // TODO: Qua tìm kiếm
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => SearchPage(
              //     isLoggedIn: widget.isLoggedIn,
              //     idUser: widget.idUser,
              //   )),
              // );
              context.push(
                '/search',
                extra: {
                  'isLoggedIn': widget.isLoggedIn,
                  'idUser': widget.idUser
                }
              );
            },
            child: Container(
              padding: EdgeInsets.all(14.r), // tăng giảm để icon vừa mắt
              decoration: BoxDecoration(
                color: AppColors.primary, // màu nền xanh lá
                // shape: BoxShape.circle, // giữ hình tròn
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isLoggedIn ? Icons.search_rounded : Icons.login,
                color: Colors.white,
                size: 24.sp, // chỉnh size icon
              ),
            ),
          ),
        ) 
      : null
    );
  }
}