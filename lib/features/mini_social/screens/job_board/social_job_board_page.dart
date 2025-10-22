import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/custom_search_add.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_appbar.dart';
import 'package:job_connect/features/mini_social/screens/job_board/social_job_board_detail_page.dart';

/// MODEL
class JobItem {
  final String title;
  final String desc;
  final String price;
  final String image;
  final String user;
  final String time;

  JobItem({
    required this.title,
    required this.desc,
    required this.price,
    required this.image,
    required this.user,
    required this.time,
  });
}

class JobBoardPage extends StatefulWidget {
  const JobBoardPage({super.key});

  @override
  State<JobBoardPage> createState() => _JobBoardPageState();
}

class _JobBoardPageState extends State<JobBoardPage> {
  final _searchCon = TextEditingController();
  final _searchFocus = FocusNode();

  /// Dữ liệu mẫu
  final List<JobItem> items = [
    JobItem(
      title: 'Tuyển nhân viên bán hàng',
      desc:
          'Bán hàng tại cửa hàng tiện lợi, làm việc theo ca, ưu tiên người có kinh nghiệm.',
      price: '3400\$',
      image: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      user: 'John',
      time: '1 hour ago',
    ),
    JobItem(
      title: 'Canon camera',
      desc: 'Máy ảnh Canon chất lượng cao, bảo hành 12 tháng, mới 99%.',
      price: '550\$',
      image: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      user: 'Sophie',
      time: '1 hour ago',
    ),
    JobItem(
      title: 'Old sofa for free',
      desc: 'Sofa cũ nhưng vẫn rất chắc chắn, ai cần thì liên hệ lấy miễn phí.',
      price: 'FREE',
      image: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      user: 'Oliver',
      time: '2 hours ago',
    ),
  ];

  String? _selectedFilter;
  final List<String> quickFilters = [
    'Tất cả',
    'Bán hàng',
    'Điện tử',
    'Nội thất',
    'Thú cưng',
    'Thời trang'
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: gọi API load lại dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        automaticallyImplyLeading: true,
        title: Text(
          'Bảng tin công việc',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: TextColors.textBrandOnbrand,
              ),
        ),
        leading: CustomAdaptiveTapEffect(
          isOpacity: true,
          onPressed: () => context.pop(),
          child: Icon(
            getAdaptiveBackIcon(context),
            size: 22.sp,
            color: IconColors.iconBrandOnbrand,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// Search + Filters (cố định)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchAdd(
                          controller: _searchCon,
                          focusNode: _searchFocus,
                          hintText: 'Tìm kiếm công việc',
                          onCheck: (query) {
                            // TODO: search
                          },
                          onAdd: () {
                            // TODO: thêm
                            context.push('/create-post');
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickFilters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final filter = quickFilters[index];
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedFilter == filter ? BackgroundColors.backgroundBrandPrimary : Colors.transparent,
                            side: BorderSide(
                              color: _selectedFilter == filter ? BorderColors.borderBrandStrong : BorderColors.borderSeparatorOpaque,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r)
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedFilter == filter) {
                                _selectedFilter = null; 
                              } else {
                                _selectedFilter = filter;
                              }
                            });
                          },
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: _selectedFilter == filter ? TextColors.textBrandOnbrand : TextColors.textDefaultPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.w),

            /// Grid cuộn bên dưới
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap:() {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context)=> SocialJobBoardDetailPage(job: item))
                        );
                      },
                      child: Card(
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
                                item.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.desc,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                    ),
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
                                item.price,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: item.price == 'FREE'
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
                                    backgroundImage: ImageUtils.getImageProvider(
                                      'https://i.pravatar.cc/100',
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      '${item.user} • ${item.time}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.favorite_border,
                                    size: 16.sp,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
