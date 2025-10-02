import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';
import 'package:job_connect/config/widgets/reusable_bottom_sheet.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String selectedFilter = "Mới nhất";
  List<FilterOption> filterOptions = [
    FilterOption(
      icon: Icons.new_releases,
      title: "Mới nhất",
      value: "Mới nhất",
      iconColor: Colors.blue,
      onTapItem: () {
        print("Chọn Mới nhất");
      },
    ),
    FilterOption(
      icon: Icons.trending_up,
      title: "Phổ biến",
      value: "Phổ biến",
      iconColor: Colors.orange,
      onTapItem: () {
        print("Chọn Phổ biến");
      },
    ),
    FilterOption(
      icon: Icons.person,
      title: "Bài của tôi",
      value: "Bài của tôi",
      iconColor: Colors.green,
      onTapItem: () {
        print("Chọn Bài của tôi");
      },
    ),
  ];

  List<FilterOption> controlOptions = [
    FilterOption(
      icon: Icons.logout,
      title: "Rời nhóm",
      value: "Rời nhóm",
      iconColor: Colors.red,
      onTapItem: () {
        print("Rời nhóm được nhấn");
      },
    ),
  ];

  bool isJoinSheetOpen = false;

  void onFolow(){

  }

  void _showInviteFriend() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chức năng mời bạn bè!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22.sp),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                var top = constraints.biggest.height;
                double collapsePercent =
                    (top - kToolbarHeight) / (200.h - kToolbarHeight);
                collapsePercent = collapsePercent.clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  background: Image.asset(
                    "assets/images/connect.png",
                    fit: BoxFit.cover,
                  ),
                  title: Opacity(
                    opacity: 1 - collapsePercent,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            "assets/images/connect.png",
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Tên Nhóm Demosss",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 60.w, bottom: 12.h),
                );
              },
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                ),
              ),
            ],
          ),
          /// Nội dung sau ảnh bìa
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tên nhóm
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    "Tên Nhóm Demo",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// Row info nhóm
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open,
                          size: 20, color: Colors.grey),
                      SizedBox(width: 6.w),
                      Text(
                        "Nhóm công khai • 1.2K thành viên",
                        style:
                            TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                /// Row nút
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // onPressed: _showJoinSheet,
                          onPressed: (){
                            setState(() => isJoinSheetOpen = true);
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                              ),
                              builder: (_) => ReusableBottomSheet(
                                options: controlOptions,
                                selectedValue: selectedFilter,
                                showRadio: false,
                                onSelected: (value) {
                                  setState(() {
                                    selectedFilter = value;
                                  });
                                },
                              ),
                            ).whenComplete(() {
                              setState(() => isJoinSheetOpen = false);
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white, // nền
                            foregroundColor: Colors.black, // màu chữ & icon
                            side: BorderSide(color: Colors.grey.shade400, width: 1), // viền
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          label: const Text("Đã tham gia"),
                          icon: Icon(
                            isJoinSheetOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showInviteFriend,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade400, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_alt, size: 20),
                          label: const Text("Mời bạn bè"),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  width: double.infinity,
                  height: 2.h,
                  color: Colors.grey.shade300
                ),
                /// Ô đăng bài
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: CircleAvatar(
                          backgroundImage:NetworkImage("https://i.pravatar.cc/150?img=15"),
                          radius: 20,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/create-post'),
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "Bạn viết gì đi...",
                              contentPadding: EdgeInsets.symmetric( vertical: 8.h, horizontal: 12.w),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.photo, color: Colors.green),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.h, bottom: 8.h),
                  width: double.infinity,
                  height: 2.h,
                  color: Colors.grey.shade300
                ),
                /// Bộ lọc
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedFilter,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                            ),
                            builder: (_) => ReusableBottomSheet(
                              headerIcon: Icons.filter_list,
                              options: filterOptions,
                              selectedValue: selectedFilter,
                              showRadio: true,
                              onSelected: (value) {
                                setState(() => selectedFilter = value);
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
                  width: double.infinity,
                  height: 2.h,
                  color: Colors.grey.shade300
                ),
              ],
            ),
          ),

          /// Danh sách bài viết
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
    );
  }
}
