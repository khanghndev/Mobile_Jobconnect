import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpgradePostingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isNew;

  const UpgradePostingButton({
    super.key,
    required this.onTap,
    this.isNew = true,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: recruiterPrimary.withValues(alpha: 0.15),
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.15),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [recruiterPrimary, recruiterSecondary],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Nâng cấp đăng tin",
                  style: TextStyle(
                    color: recruiterPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isNew) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.new_releases_rounded,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "MỚI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}