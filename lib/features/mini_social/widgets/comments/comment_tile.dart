import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class CommentTile extends StatelessWidget {
  final String username;
  final String text;
  final String time;
  final String icon;
  final int count;
  final VoidCallback onReplyTap;
  final VoidCallback onReactTap;

  const CommentTile({
    super.key,
    required this.username,
    required this.text,
    required this.time,
    required this.icon,
    required this.count,
    required this.onReplyTap,
    required this.onReactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundImage: ImageUtils.getImageProvider('https://i.pravatar.cc/150?img=1'),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "$username ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                    children: [
                      TextSpan(
                        text: text,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: onReactTap,
                    child: Text("Thích", style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Text("Trả lời", style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                  ),
                  SizedBox(width: 12.w),
                  Text(time, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                  const Spacer(),
                  if (count > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text(icon, style: TextStyle(fontSize: 12.sp)),
                          SizedBox(width: 2.w),
                          Text('$count', style: TextStyle(fontSize: 11.sp)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
