import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'featured_job_card.dart';

class FeaturedJobsList extends StatelessWidget {
  final List<JobPostingModel> jobs;
  final String idUser;

  const FeaturedJobsList({
    super.key,
    required this.jobs,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'Hiện chưa có công việc nào',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: jobs.length > 4 ? 4 : jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 425),
            child: SlideAnimation(
              verticalOffset: 60.h,
              child: FadeInAnimation(
                child: FeaturedJobCard(
                  job: job,
                  idUser: idUser,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
