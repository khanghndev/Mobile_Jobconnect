import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'featured_job_card.dart';
import 'package:provider/provider.dart';

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

    return Consumer<JobSavedViewModel>(
      builder: (context, jobSavedVM, child) {
        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length > 4 ? 4 : jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final isSaved = jobSavedVM.savedJobs.any(
                (saved) => saved.idJobPost == job.idJobPost && saved.idUser == idUser,
              );

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 425),
                child: SlideAnimation(
                  verticalOffset: 60.h,
                  child: FadeInAnimation(
                    child: FeaturedJobCard(
                      job: job,
                      idUser: idUser,
                      isSaved: isSaved,
                      onSaveToggle: () async {
                        if (isSaved) {
                          await jobSavedVM.deleteSavedJob(job.idJobPost, idUser);
                        } else {
                          await jobSavedVM.saveJob(
                            JobSavedModel(
                              idJobPost: job.idJobPost,
                              idUser: idUser,
                            ),
                          );
                        }
                        // Reload lại danh sách đã lưu sau khi thay đổi
                        await jobSavedVM.fetchSavedJobsByUser(idUser);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
