import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/image_review_zoom.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/custom_bottom_button.dart';

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
class SocialJobBoardDetailPage extends StatelessWidget {
  final JobItem job;
  const SocialJobBoardDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        automaticallyImplyLeading: true,
        title: Text(
          job.title,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Ảnh chính
              AspectRatio(
                aspectRatio: 1.2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageReviewZoom(imageUrl: job.image),
                      ),
                    );
                  },
                  child: Image.network(
                    job.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Tiêu đề
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    /// Giá
                    Text(
                      job.price,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: (job.price.toUpperCase() == 'FREE')
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    /// Người đăng + thời gian
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundImage: ImageUtils.getImageProvider('https://i.pravatar.cc/100'),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${job.user} • ${job.time}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Icon(Icons.favorite_border,
                            size: 20.sp, color: Colors.red),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    /// Mô tả
                    Text(
                      'Mô tả',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      job.desc,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomButton(
        onPressed: (){

        },
        title: 'Liên hệ',
      )
    );
  }
}
