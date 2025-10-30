import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SaveBottomSheet extends StatelessWidget {
  final List<String> folders;
  final Map<String, int> folderSavedCount; // Số bài viết đã lưu trong folder
  final void Function(String folderName) onSaved;
  final void Function(String folderName) onDelete;
  final VoidCallback onCreateFolder;
  final void Function(String folderName)? onSelectFolder;

  const SaveBottomSheet({
    super.key,
    required this.folders,
    required this.onSaved,
    required this.onDelete,
    required this.onCreateFolder,
    this.onSelectFolder,
    required this.folderSavedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
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
                  child: Icon(Icons.add_rounded,
                      size: 26.sp, color: theme.primaryColor),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => context.pop(),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.close_rounded,
                      size: 24.sp, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Flexible(
            child: folders.isEmpty
                ? Center(
                    child: Text(
                      "Chưa có bộ sưu tập nào",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: folders.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      final folderName = folders[i];
                      final savedCount = folderSavedCount[folderName] ?? 0;
                      return GestureDetector(
                        onTap: () => onSelectFolder?.call(folderName),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.03),
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
                                  color: theme.primaryColor.withValues(alpha:0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.folder_rounded,
                                    size: 26.sp, color: theme.primaryColor),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      folderName,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "$savedCount bài viết đã lưu",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => onSaved(folderName),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10.w),
                                  child: Icon(Icons.bookmark_add,
                                      color: Colors.white, size: 20.sp),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => onDelete(folderName),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10.w),
                                  child: Icon(Icons.delete,
                                      color: Colors.white, size: 18.sp),
                                ),
                              ),
                            ],
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
