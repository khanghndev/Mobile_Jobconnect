import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShareBottomSheet extends StatefulWidget {
  final List<Map<String, String>> initialUsers;

  const ShareBottomSheet({super.key, required this.initialUsers});

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  late List<Map<String, String>> users;

  @override
  void initState() {
    super.initState();
    users = List.from(widget.initialUsers); // copy danh sách ban đầu
  }

  void _removeUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
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
          // drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Row(
            children: [
              Text(
                "Chia sẻ tới",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.close_rounded, size: 24.sp, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 12.h),
              itemCount: users.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final user = users[i];

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Colors.white,
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
                      // Avatar
                      CircleAvatar(
                        radius: 26.r,
                        backgroundImage: NetworkImage(user['avatar']!),
                      ),
                      SizedBox(width: 14.w),

                      // Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name']!,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Nhấn để chia sẻ",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Send button (circle)
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: Icon(Icons.send, color: Colors.white, size: 18.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Delete button
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => _removeUser(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: Icon(Icons.delete, color: Colors.white, size: 18.sp),
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
}
