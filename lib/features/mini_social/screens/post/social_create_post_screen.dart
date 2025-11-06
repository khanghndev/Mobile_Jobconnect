import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialCreatePostScreen extends StatefulWidget {
  const SocialCreatePostScreen({super.key});

  @override
  State<SocialCreatePostScreen> createState() => _SocialCreatePostScreenState();
}

class _SocialCreatePostScreenState extends State<SocialCreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showFullOptions = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppbar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo bài viết",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Consumer2<SocialPostViewModel, UserViewModel>(
              builder: (context, postVm, userVm, child) {
                final isEmpty = _controller.text.trim().isEmpty;

                return TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(40.w, 30.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    backgroundColor: isEmpty || _isLoading ? Colors.grey : theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: isEmpty || _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final idUser = userVm.currentUser?.idUser ?? '';
                          final content = _controller.text.trim();

                          // Gọi API createPost với các biến
                          await postVm.createPost(
                            idUser: idUser,
                            idGroup: '',
                            content: content,
                            imageUrl: '',
                            videoUrl: '',
                            visibility: 'public',
                            postType: PostType.post.name,
                            hashtags: [],
                          );

                          setState(() => _isLoading = false);

                          if (postVm.isSuccess && context.mounted) {
                            context.pop();
                            SnackbarApp.show(
                              context,
                              title: 'Thành công',
                              message: 'Bài viết đã đăng thành công',
                              backgroundColor: BackgroundColors.backgroundSuccessPrimary,
                            );
                          } else if (postVm.errorMessage == null && context.mounted){
                            context.pop();
                            SnackbarApp.show(
                              context,
                              title: 'Thất bại',
                              message: 'Bài viết đăng thất bại: ${postVm.errorMessage}',
                              backgroundColor: BackgroundColors.backgroundErrorPrimary,
                            );
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text("Đăng", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                );
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Consumer<UserViewModel>(
                  builder: (context, userVm, child) {
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: ImageUtils.getImageProvider(userVm.currentUser?.avatarUrl ?? ''),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userVm.currentUser?.userName ?? "Người dùng ${AppStrings.appName}",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                            ),
                            Row(
                              children: [
                                Icon(
                                  userVm.roleName!.toLowerCase() == UserRole.candidate.name ? Icons.verified_user : Icons.verified, 
                                  color: Colors.blue, 
                                  size: 16.sp
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  userVm.roleName!.toLowerCase() == UserRole.candidate.name ? "Ứng viên" : "Nhà tuyển dụng", 
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    cursorColor: Colors.blue[200],
                    style: TextStyle(fontSize: 16.sp),
                    decoration: const InputDecoration(
                      hintText: "Bạn muốn nói về điều gì?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => setState(() => _showFullOptions = false),
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),

          // Overlay loading toàn màn hình
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha:0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: _showFullOptions ? _buildExpandedGrid() : _buildCompactRow(),
    );
  }

  Widget _buildCompactRow() {
    final icons = [
      {'icon': Icons.image, 'color': Colors.blue},
      {'icon': Icons.gif_box, 'color': Colors.lightBlue},
      {'icon': Icons.poll, 'color': Colors.green},
      {'icon': Icons.favorite, 'color': Colors.redAccent},
      {'icon': Icons.campaign, 'color': Colors.orange},
      {'icon': Icons.event, 'color': Colors.purple},
      {'icon': Icons.celebration, 'color': Colors.teal},
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: icons.map((item) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildCircleIcon(
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                    onPressed: () {},
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: _buildCircleIcon(
            icon: Icons.arrow_drop_up,
            color: Colors.grey,
            onPressed: () => setState(() => _showFullOptions = true),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedGrid() {
    final options = [
      {'icon': Icons.image, 'label': 'Photo/Video', 'color': Colors.blue},
      {'icon': Icons.gif_box, 'label': 'GIF', 'color': Colors.lightBlue},
      {'icon': Icons.poll, 'label': 'Poll', 'color': Colors.green},
      {'icon': Icons.favorite, 'label': 'Adoption', 'color': Colors.redAccent},
      {'icon': Icons.campaign, 'label': 'Lost Notice', 'color': Colors.orange},
      {'icon': Icons.event, 'label': 'Event', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 100.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Add to your post", style: TextStyle(fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () => setState(() => _showFullOptions = false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 2,
          ),
          itemBuilder: (_, i) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        options[i]['icon'] as IconData, 
                        color: options[i]['color'] as Color,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        options[i]['label'] as String,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.add),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircleIcon({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
