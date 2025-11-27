import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/filter_panel.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/job_card.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class JobListDraggableSheet extends StatefulWidget {
  final bool isLoading;
  final List<JobPostingModel> jobsInView;
  final String? currentCity;
  final String idUser;
  final SearchMode? searchMode;
  final double? radiusKm;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onLocationPressed;

  const JobListDraggableSheet({
    super.key,
    required this.isLoading,
    required this.jobsInView,
    required this.idUser,
    this.currentCity,
    this.searchMode,
    this.radiusKm,
    this.onFilterPressed,
    this.onLocationPressed,
  });

  @override
  State<JobListDraggableSheet> createState() => _JobListDraggableSheetState();
}

class _JobListDraggableSheetState extends State<JobListDraggableSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.18, 0.5, 0.75, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),

          /// *** GIẢI PHÁP QUAN TRỌNG NHẤT: SCROLLVIEW DÙNG CHUNG scrollController ***
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                _buildHeader(theme),

                SizedBox(height: 12.h),

                ..._buildJobList(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ---------------------- HEADER ----------------------
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          // --- Grabber ---
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_outline_rounded,
                        size: 16.sp, color: theme.primaryColor),
                    SizedBox(width: 6.w),
                    Text(
                      widget.isLoading && widget.jobsInView.isEmpty
                          ? "Đang tìm..."
                          : "${widget.jobsInView.length} việc làm",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              if (widget.currentCity != null &&
                  widget.currentCity!.isNotEmpty)
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16.sp,
                            color: theme.colorScheme.onSurfaceVariant),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            widget.currentCity!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 10.h),

          Row(
            children: [
              if (widget.searchMode == SearchMode.radius &&
                  widget.radiusKm != null)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onFilterPressed,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              size: 18.sp, color: theme.primaryColor),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              "Bán kính ${widget.radiusKm!.toInt()} km",
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18.sp, color: theme.hintColor),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(width: 10.w),

              GestureDetector(
                onTap: widget.onLocationPressed,
                child: Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.my_location_rounded,
                      color: theme.primaryColor, size: 22.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------------- LIST ----------------------
  List<Widget> _buildJobList(ThemeData theme) {
    if (widget.jobsInView.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            widget.isLoading
                ? "Đang tìm việc quanh đây..."
                : "Không có việc nào trong khu vực bản đồ.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ];
    }

    return widget.jobsInView
        .map(
          (job) => Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: JobCard(
              jobPosting: job,
              idUser: widget.idUser,
            ),
          ),
        )
        .toList();
  }
}
