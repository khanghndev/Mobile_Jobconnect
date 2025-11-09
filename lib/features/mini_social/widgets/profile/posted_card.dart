import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class DiscoverCard extends StatelessWidget {
  final SocialPostModel socialPostModel;
  const DiscoverCard({super.key, required this.socialPostModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              socialPostModel.imageUrl ?? '',
              height: 100.h,
              width: 100.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppImages.connect,
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 94.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          StringUtils.removeHtmlTags(socialPostModel.content),
                          style: TextStyle(
                            fontSize: 14.sp, 
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      
                      Icon(Icons.more_vert, color: Colors.grey, size: 20.sp),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.pink, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text("${socialPostModel.likesCount}", style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 16.w),
                      Icon(Icons.comment, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text("${socialPostModel.commentsCount}", style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 16.w),
                      Icon(Icons.remove_red_eye, color: Colors.grey, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text("${socialPostModel.sharesCount}", style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
