import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandedGridIcons extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final VoidCallback onCollapse;

  const ExpandedGridIcons({
    super.key,
    required this.options,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo
          Center(
            child: Container(
              width: 100.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Header + Collapse button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thêm vào bài đăng của bạn",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down, size: 24.r),
                onPressed: onCollapse,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Grid scrollable
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 2,
              ),
              itemBuilder: (_, i) {
                final item = options[i];
                return GestureDetector(
                  onTap: item['onPressed'] as void Function(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                              size: 30.r,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.add, size: 24.r),
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
