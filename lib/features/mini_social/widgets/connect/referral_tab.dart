import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/config/widgets/info_row.dart';

class ReferralTabWidget extends StatelessWidget {
  final String referralCode;
  final int rewardPoints;
  final String imagePath;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const ReferralTabWidget({
    super.key,
    required this.referralCode,
    required this.rewardPoints,
    required this.imagePath,
    required this.onShare,
    required this.onCopy,
  });
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Expanded(
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 200.h,
                ),
                SizedBox(height: 20.h),
                Text(
                  "Mời bạn bè ngay, nhận $rewardPoints điểm cho mỗi người bạn!",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        referralCode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: onCopy,
                        child: Text(
                          "Sao chép",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                InfoRow(
                  icon: Icons.star,
                  text: "Mời bạn bè của bạn\nGửi liên kết giới thiệu cá nhân cho bạn bè.",
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                InfoRow(
                  icon: Icons.star,
                  text: "Nhận điểm thưởng\nMỗi người bạn tham gia sẽ giúp bạn nhận $rewardPoints điểm.",
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          
          CustomButtomLeadingIcon(
            onPressed: () => onShare,
            text: "Chia sẻ mã giới thiệu",
            icon: Icons.share_outlined,
            iconColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.primaryColor,
            textColor: theme.colorScheme.onPrimary,
            borderRadius: 50.r,
          ),
        ],
      ),
    );
  }
}
