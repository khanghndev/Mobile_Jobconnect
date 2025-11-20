import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/image_url.dart';

class GroupAppbar extends StatelessWidget {
  final String groupName;
  final String groupCoverImage;
  final String groupImage;
  final VoidCallback? onMorePressed;

  const GroupAppbar({
    super.key,
    required this.groupName,
    required this.groupImage,
    required this.groupCoverImage,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 22.sp,
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          var top = constraints.biggest.height;
          double collapsePercent = (top - kToolbarHeight) / (200.h - kToolbarHeight);
          collapsePercent = collapsePercent.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            background: Image(image: ImageUtils.getImageProvider(groupCoverImage), fit: BoxFit.cover),
            title: Opacity(
              opacity: 1 - collapsePercent,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image(
                      image: ImageUtils.getImageProvider(
                        groupImage.isNotEmpty ? groupImage : AppImages.logo,
                      ),
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
            onPressed: onMorePressed,
            icon: Icon(Icons.more_vert, color: Colors.black, size: 22.sp,),
          ),
        ),
      ],
    );
  }
}