import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/features/job/widgets/job_detail/similar_job_card.dart';

class SimilarJobsSection extends StatelessWidget {
  final List<Map<String, String>> similarJobs;
  final VoidCallback? onSeeAll;
  final Function(Map<String, String> job)? onTapJob;

  const SimilarJobsSection({
    super.key,
    required this.similarJobs,
    this.onSeeAll,
    this.onTapJob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      color: theme.primaryColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Việc Làm Tương Tự",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    "Xem Tất Cả",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 220.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: similarJobs.length,
              itemBuilder: (context, index) {
                final job = similarJobs[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: SlideAnimation(
                    horizontalOffset: 50.w,
                    child: FadeInAnimation(
                      child: SimilarJobCard(
                        title: job["title"] ?? "",
                        company: job["company"] ?? "",
                        salary: job["salary"] ?? "",
                        location: job["location"] ?? "",
                        onTap: () => onTapJob?.call(job),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
