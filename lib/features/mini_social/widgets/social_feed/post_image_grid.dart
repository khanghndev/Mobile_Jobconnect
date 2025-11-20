import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class PostImageGrid extends StatelessWidget {
  final List<String> imagePaths;
  final void Function(String path)? onRemoveImage; 
  const PostImageGrid({
    super.key,
    required this.imagePaths,
    this.onRemoveImage,
  });

  Widget buildImage(String path,{bool overlay = false, int? extraCount, bool canRemove = true}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh hiển thị
          Image(
            image: ImageUtils.getImageProvider(path),
            fit: BoxFit.cover,
          ),

          // Overlay nếu >4 ảnh
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

          //  Nút xóa ảnh
          if (!overlay && canRemove && onRemoveImage != null)
            Positioned(
              top: 6.w,
              right: 6.w,
              child: GestureDetector(
                onTap: () => onRemoveImage!(path),
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
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
      return AspectRatio(
        aspectRatio: 1,
        child: buildImage(imagePaths[0]),
      );
    }

    if (total == 2) {
      return Row(
        children: imagePaths.asMap().entries.map((entry) {
          final p = entry.value;
          final isLast = entry.key == imagePaths.length - 1;
          return Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
                child: buildImage(p),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (total == 3) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: AspectRatio(
                      aspectRatio: 1, child: buildImage(imagePaths[0]))),
              SizedBox(width: 8.w),
              Expanded(
                  child: AspectRatio(
                      aspectRatio: 1, child: buildImage(imagePaths[1]))),
            ],
          ),
          SizedBox(height: 8.h),
          AspectRatio(aspectRatio: 2, child: buildImage(imagePaths[2])),
        ],
      );
    }

    // 4 hoặc nhiều hơn → 2x2 grid
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
        return buildImage(
          imagePaths[index],
          overlay: overlay,
          extraCount: overlay ? extraCount : null,
        );
      },
    );
  }
}
