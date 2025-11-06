import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class JobApplicationDetailShimmer extends StatelessWidget {
  const JobApplicationDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.4),
        highlightColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusShimmer(),
            SizedBox(height: 16.h),
            _buildJobCardShimmer(),
            SizedBox(height: 16.h),
            _buildSectionShimmer(),
            SizedBox(height: 16.h),
            _buildTextBlockShimmer(),
            SizedBox(height: 16.h),
            _buildSectionShimmer(),
            SizedBox(height: 16.h),
            _buildTextBlockShimmer(),
            SizedBox(height: 16.h),
            _buildSectionShimmer(),
            SizedBox(height: 16.h),
            _buildCompanyInfoShimmer(),
            SizedBox(height: 16.h),
            _buildSectionShimmer(),
            SizedBox(height: 16.h),
            _buildCvAndLetterShimmer(),
            SizedBox(height: 24.h),
            _buildButtonShimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusShimmer() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
    );
  }

  Widget _buildJobCardShimmer() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return Container(
      width: 180.w,
      height: 22.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  Widget _buildTextBlockShimmer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Container(
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfoShimmer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: List.generate(
          2,
          (i) => Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Container(
                  height: 24.r,
                  width: 24.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCvAndLetterShimmer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 24.r,
                width: 24.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonShimmer() {
    return Container(
      height: 48.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}