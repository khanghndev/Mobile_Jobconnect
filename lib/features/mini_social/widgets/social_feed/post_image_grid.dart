import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostImageGrid extends StatelessWidget {
  final List<String> imagePaths;
  final bool isNetwork;

  const PostImageGrid({
    super.key,
    required this.imagePaths,
    this.isNetwork = false,
  });

  Widget buildImage(String path, {bool overlay = false, int? extraCount}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: isNetwork
                ? ImageUtils.getImageProvider(path)
                : FileImage(File(path)),
            fit: BoxFit.cover,
          ),
          if (overlay && extraCount != null)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Text(
                '+$extraCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = imagePaths.length;
    if (total == 0) return const SizedBox.shrink();

    int displayCount = total > 4 ? 4 : total;
    int extraCount = total > 4 ? total - 4 : 0;

    if (total == 1) {
      return AspectRatio(aspectRatio: 1, child: buildImage(imagePaths[0]));
    }

    if (total == 2) {
      return Row(
        children: imagePaths.map((p) => Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: EdgeInsets.only(right: p != imagePaths.last ? 8.w : 0),
              child: buildImage(p),
            ),
          ),
        )).toList(),
      );
    }

    if (total == 3) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: AspectRatio(aspectRatio: 1, child: buildImage(imagePaths[0]))),
              SizedBox(width: 8.w),
              Expanded(child: AspectRatio(aspectRatio: 1, child: buildImage(imagePaths[1]))),
            ],
          ),
          SizedBox(height: 8.h),
          AspectRatio(aspectRatio: 2, child: buildImage(imagePaths[2])),
        ],
      );
    }

    // 4 hoặc nhiều hơn → 2x2, ảnh cuối cùng overlay nếu nhiều hơn 4
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        bool overlay = index == 3 && extraCount > 0;
        return buildImage(imagePaths[index], overlay: overlay, extraCount: overlay ? extraCount : null);
      },
    );
  }
}