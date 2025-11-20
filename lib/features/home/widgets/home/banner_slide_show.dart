import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';

class BannerSlideshow extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final bool isLoggedIn;
  final String? idUser;

  const BannerSlideshow({
    super.key,
    required this.banners,
    required this.isLoggedIn,
    this.idUser,
  });

  @override
  State<BannerSlideshow> createState() => _BannerSlideshowState();
}

class _BannerSlideshowState extends State<BannerSlideshow> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: widget.banners.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              final isActive = index == _currentBannerIndex;
              final scale = isActive ? 1.0 : 0.92;
              final verticalMargin = isActive ? 0.0 : 10.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutSine,
                transform: Matrix4.identity()..scale(scale),
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: verticalMargin.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: [
                      banner['color'] as Color,
                      banner['endColor'] ?? (banner['color'] as Color).withValues(alpha:0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (banner['color'] as Color).withValues(alpha:0.4),
                      blurRadius: isActive ? 15 : 8,
                      offset: Offset(0, isActive ? 8 : 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24.r),
                    onTap: () => _onHandleBannerTap(banner),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title'],
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  banner['description'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha:0.88),
                                    fontSize: 13.5.sp,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () => _onHandleBannerTap(banner),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha:0.25),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    elevation: 0,
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha:0.5),
                                      width: 1,
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  label: Text(
                                    "Chi Tiết",
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Icon(
                                banner['icon'] as IconData? ?? Icons.interests_rounded,
                                color: Colors.white.withValues(alpha:0.85),
                                size: 55.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: _currentBannerIndex == index ? 28.w : 10.w,
              height: 10.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: _currentBannerIndex == index
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface.withValues(alpha:0.2),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _onHandleBannerTap(Map<String, dynamic> banner) {
    if (!widget.isLoggedIn) {
      LoginRequiredDialog.show(context, isLoggedIn: false);
      return;
    }

    switch (banner['value']) {
      case 1:
        NavigationPage.goToUniJobsTab(context);
        break;
      case 2:
        context.push('/chat/ai');
        break;
      case 3:
        context.push(
          '/home/cv',
          extra: {
            'isLoggedIn': widget.isLoggedIn,
            'idUser': widget.idUser,
          }
        );
        break;
      case 4:
        context.push(
          '/home/company', 
          extra: { "idUser" : widget.idUser,}
        );
        break;
    }
  }
}
