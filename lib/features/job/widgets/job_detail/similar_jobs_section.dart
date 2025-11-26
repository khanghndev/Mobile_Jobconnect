import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/features/home/widgets/home/section_header.dart';
import 'package:job_connect/features/job/widgets/job_detail/similar_job_card.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.explore_outlined,
            title: "Việc Làm Tương Tự",
            onSeeAll: () {
              NavigationPage.goToSearchTab(context);
            },
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
