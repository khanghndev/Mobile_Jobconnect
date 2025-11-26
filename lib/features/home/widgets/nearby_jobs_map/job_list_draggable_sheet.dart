import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/filter_panel.dart';
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
  final SearchMode? searchMode;
  final double? radiusKm;

  const JobListDraggableSheet({
    super.key,
    required this.isLoading,
    required this.jobsInView,
    required this.sheetAnimationController,
    required this.showJobList,
    required this.onSheetStateChanged,
    required this.idUser,
    this.currentCity,
    this.searchMode,
    this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.18, 0.5, 0.75, 0.9],
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            final currentSheetSize =
                scrollController.position.viewportDimension /
                    MediaQuery.of(context).size.height;
            if (currentSheetSize > 0.22 && !showJobList) {
              onSheetStateChanged(true);
              sheetAnimationController.forward();
            } else if (currentSheetSize <= 0.22 && showJobList) {
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
              // Header có thể kéo được - grabber ngay đầu, không có padding top
              FadeTransition(
                opacity: sheetAnimationController,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Grabber - ở ngay đầu sheet
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                        child: Container(
                          width: 50.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      // Title và info
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isLoading && jobsInView.isEmpty
                                        ? "Đang tìm việc làm..."
                                        : "${jobsInView.length} việc làm",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  if (searchMode == SearchMode.radius && radiusKm != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        "Trong bán kính ${radiusKm!.toInt()} km",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    )
                                  else if (searchMode == SearchMode.location && currentCity != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        "Tại $currentCity",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isLoading && jobsInView.isNotEmpty)
                              SizedBox(
                                width: 18.w,
                                height: 18.w,
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: (isLoading && jobsInView.isEmpty)
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Text(
                            currentCity == null
                                ? "Vui lòng bật vị trí..."
                                : "Không có việc làm nào tại đây.",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : jobsInView.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.w),
                              child: Text(
                                "Không có việc làm nào trong vùng bản đồ này.",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.hintColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            itemCount: jobsInView.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
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
