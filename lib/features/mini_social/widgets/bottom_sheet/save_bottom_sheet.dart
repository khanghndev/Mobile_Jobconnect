import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';

const String kDefaultFolder = 'Bộ sưu tập yêu thích';

class SaveBottomSheet extends StatelessWidget {
  final List<String> folders;
  final Map<String, int> folderSavedCount;
  final void Function(String folderName) onSaved;
  final void Function(String folderName) onDelete;
  final VoidCallback onCreateFolder;
  final void Function(String folderName)? onSelectFolder;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefesh;

  const SaveBottomSheet({
    super.key,
    required this.folders,
    required this.onSaved,
    required this.onDelete,
    required this.onCreateFolder,
    this.onSelectFolder,
    required this.folderSavedCount,
    this.isLoading = false,
    this.errorMessage,
    this.onRefesh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Always ensure default folder appears first and only once
    final List<String> allFolders = [
      if (!folders.contains(kDefaultFolder)) kDefaultFolder,
      ...folders,
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          // Header row
          Row(
            children: [
              Text(
                "Lưu vào bộ sưu tập",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: onCreateFolder,
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.add_rounded, size: 26.sp, color: theme.primaryColor),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => context.pop(),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.close_rounded, size: 24.sp, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Flexible(
            child: isLoading
                ? _buildLoadingShimmer(theme)
                : errorMessage != null
                    ? BackgroundErrorState(
                        title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.\n $errorMessage",
                        onRetry: () => onRefesh?.call(),
                      )
                    : allFolders.isEmpty
                        ? Center(
                            child: Text(
                              "Chưa có bộ sưu tập nào",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: allFolders.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (_, i) {
                              final folderName = allFolders[i];
                              final savedCount = folderSavedCount[folderName] ?? 0;
                              final isDefault = folderName == kDefaultFolder;

                              return GestureDetector(
                                onTap: () => onSelectFolder?.call(folderName),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Card chính
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(color: Colors.grey[300]!),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48.w,
                                            height: 48.w,
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.folder_rounded, size: 26.sp, color: theme.primaryColor),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  folderName,
                                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text("$savedCount bài viết đã lưu", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(50),
                                            onTap: () => onSaved(folderName),
                                            child: Container(
                                              decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                                              padding: EdgeInsets.all(10.w),
                                              child: Icon(Icons.bookmark_add, color: Colors.white, size: 20.sp),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          isDefault
                                            ? Padding(
                                                padding: EdgeInsets.only(left: 2.w),
                                                child: Icon(Icons.lock_outline, color: Colors.grey, size: 20.sp),
                                              )
                                            : InkWell(
                                                borderRadius: BorderRadius.circular(50),
                                                onTap: () => onDelete(folderName),
                                                child: Container(
                                                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                                  padding: EdgeInsets.all(10.w),
                                                  child: Icon(Icons.delete, color: Colors.white, size: 18.sp),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),

                                    // Badge "Mặc định" đặt ở góc trên-left (nổi trên card)
                                    if (isDefault)
                                      Positioned(
                                        top: -6.h,
                                        left: -6.w,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            borderRadius: BorderRadius.circular(8.r),
                                            boxShadow: [
                                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: Offset(0, 2)),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.lock, size: 12.sp, color: Colors.white),
                                              SizedBox(width: 6.w),
                                              Text('Mặc định', style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  /// Shimmer/placeholder khi loading
  Widget _buildLoadingShimmer(ThemeData theme) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: 5,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 80.w,
                    height: 12.h,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}