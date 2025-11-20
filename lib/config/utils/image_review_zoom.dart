import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class ImageReviewZoom extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImageReviewZoom({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.3),
      body: Stack(
        children: [
          /// Ảnh zoom
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: heroTag != null
                  ? Hero(
                      tag: heroTag!,
                      child: Image.network(imageUrl),
                    )
                  : Image.network(imageUrl),
            ),
          ),

          /// Nút đóng
          Positioned(
            top: 40.h,
            right: 20.w,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: IconColors.iconBrandOnbrand,
                size: 30.sp, // size theo sp
              ),
              onPressed: () => context.pop(),
            ),
          ),

          /// Nút phụ (download/share)
          Positioned(
            bottom: 40.h,
            right: 20.w,
            child: IconButton(
              icon: Icon(
                Icons.download,
                color: IconColors.iconBrandOnbrand,
                size: 30.sp,
              ),
              onPressed: () {
                // TODO: hành động phụ (vd: tải ảnh, chia sẻ...)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đang xử lý tải ảnh...")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
