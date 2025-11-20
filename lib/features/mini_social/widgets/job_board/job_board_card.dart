import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class JobBoardCard extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors; // overlay gradient nếu có
  final double shadowOpacity; // opacity cho shadow
  final Color borderColor; // màu viền
  final double borderWidth; // độ dày viền

  const JobBoardCard({
    super.key,
    required this.imagePath,
    this.width = 210,
    this.height = 320,
    this.borderRadius = 14,
    this.gradientColors,
    this.shadowOpacity = 0.45,
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.06),
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(0, 4),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh chính
            Image(
              image: ImageUtils.getImageProvider(imagePath),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}