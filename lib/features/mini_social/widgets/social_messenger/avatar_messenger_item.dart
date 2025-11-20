import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class AvatarMessengerItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final double radius;

  const AvatarMessengerItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.radius = 30.0, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: radius.r,
              backgroundImage: ImageUtils.getImageProvider(imageUrl),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: 100.w,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}