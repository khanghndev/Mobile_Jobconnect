import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileShimmer extends StatelessWidget {
  const EditProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Shimmer.fromColors(
        baseColor: theme.dividerColor.withValues(alpha: 0.2),
        highlightColor: theme.dividerColor.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 32.h),

            // Section title
            Container(height: 20.h, width: 120.w, color: Colors.grey),
            SizedBox(height: 16.h),

            // TextField placeholders
            ...List.generate(8, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),

            SizedBox(height: 32.h),
            // Section title
            Container(height: 20.h, width: 150.w, color: Colors.grey),
            SizedBox(height: 16.h),

            // TextField placeholders
            ...List.generate(5, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),

            SizedBox(height: 35.h),
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
