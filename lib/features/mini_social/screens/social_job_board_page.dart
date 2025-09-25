import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/create_post_box.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/job_board_list.dart';

class JobBoardPage extends StatefulWidget {
  const JobBoardPage({super.key});

  @override
  State<JobBoardPage> createState() => _JobBoardPageState();
}

class _JobBoardPageState extends State<JobBoardPage> {
  final List<Map<String, String>> items = [
    {
      'title': 'Tuyển nhân viên bán hàng',
      'desc': 'Bán hàng tại cửa hàng tiện lợi, làm việc theo ca, ưu tiên người có kinh nghiệm.',
      'price': '3400\$',
      'image': 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      'user': 'John',
      'time': '1 hour ago',
    },
    {
      'title': 'Canon camera',
      'desc': 'Máy ảnh Canon chất lượng cao, bảo hành 12 tháng, mới 99%.',
      'price': '550\$',
      'image': 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      'user': 'Sophie',
      'time': '1 hour ago',
    },
    {
      'title': 'Old sofa for free',
      'desc': 'Sofa cũ nhưng vẫn rất chắc chắn, ai cần thì liên hệ lấy miễn phí.',
      'price': 'FREE',
      'image': 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      'user': 'Oliver',
      'time': '2 hours ago',
    },
  ];

  final List<String> _selectedFilters = [];
  final List<String> quickFilters = ['Tất cả', 'Bán hàng', 'Điện tử', 'Nội thất', 'Thú cưng', 'Thời trang'];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: gọi API load lại dữ liệu
    print("Refreshed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    children: [
                      /// Search + filter icon
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home_outlined),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                         
                          IconButton(
                            icon: const Icon(Icons.post_add),
                            onPressed: () {
                              _showFilterBottomSheet(context);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      /// Quick Filters
                      SizedBox(
                        height: 36.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: quickFilters.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final filter = quickFilters[index];
                            final selected = _selectedFilters.contains(filter);
                            return ChoiceChip(
                              label: Text(filter),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedFilters.add(filter);
                                  } else {
                                    _selectedFilters.remove(filter);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // /// Create Post Box
                      // CreatePostBox(
                      //   avatarUrl: "https://i.pravatar.cc/150?img=3",
                      //   userName: "Nguyễn Văn A",
                      //   userLevel: "Cấp 3",
                      //   onPost: () {
                      //     // Xử lý đăng bài
                      //   },
                      // ),

                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              /// GridView Products
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item['desc'] ?? '',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                item['price']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: item['price'] == 'FREE'
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10.r,
                                    backgroundImage: const NetworkImage(
                                      'https://i.pravatar.cc/100',
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      '${item['user']} • ${item['time']}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.favorite_border, size: 16.sp, color: Colors.red),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final List<String> allFilters = [
      'Art',
      'Consumer electronics',
      'Sport',
      'Home',
      'Fashion',
      'Pets',
      'Vehicles'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bộ lọc',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: allFilters.map((filter) {
                    final isSelected = _selectedFilters.contains(filter);
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFilters.add(filter);
                          } else {
                            _selectedFilters.remove(filter);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
