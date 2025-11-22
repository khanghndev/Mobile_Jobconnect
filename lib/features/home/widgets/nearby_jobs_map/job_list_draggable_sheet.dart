import 'package:flutter/material.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/job_card.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class JobListDraggableSheet extends StatelessWidget {
  final bool isLoading;
  final List<JobPostingModel> jobsInView;
  final AnimationController sheetAnimationController;
  final bool showJobList;
  final Function(bool) onSheetStateChanged;
  final String? currentCity;
  final String idUser;

  const JobListDraggableSheet({
    super.key,
    required this.isLoading,
    required this.jobsInView,
    required this.sheetAnimationController,
    required this.showJobList,
    required this.onSheetStateChanged,
    required this.idUser,
    this.currentCity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.5, 0.85],
      builder: (BuildContext context, ScrollController scrollController) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            final currentSheetSize =
                scrollController.position.viewportDimension /
                    MediaQuery.of(context).size.height;
            if (currentSheetSize > 0.18 && !showJobList) {
              onSheetStateChanged(true);
              sheetAnimationController.forward();
            } else if (currentSheetSize <= 0.18 && showJobList) {
              onSheetStateChanged(false);
              sheetAnimationController.reverse();
            }
          }
        });

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha(50),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Grabber
              Container(
                width: 45,
                height: 5.5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withAlpha(200),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FadeTransition(
                opacity: sheetAnimationController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLoading && jobsInView.isEmpty
                            ? "Đang tìm việc làm..."
                            : "${jobsInView.length} việc làm trong khu vực",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLoading && jobsInView.isNotEmpty)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: (isLoading && jobsInView.isEmpty)
                    ? Center(
                        child: Text(
                          currentCity == null
                              ? "Vui lòng bật vị trí..."
                              : "Không có việc làm nào tại đây.",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      )
                    : jobsInView.isEmpty
                        ? Center(
                            child: Text(
                              "Không có việc làm nào trong vùng bản đồ này.",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: jobsInView.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final job = jobsInView[index];
                              return JobCard(
                                jobPosting: job,
                                idUser: idUser,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
