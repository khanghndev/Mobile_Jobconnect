import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerRecruiterItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? itemColor;

  const DrawerRecruiterItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isSelected = false,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
    final color = itemColor ??
        (isSelected
            ? recruiterPrimary
            : Colors.grey.shade700);

    return Material(
      color: isSelected 
          ? recruiterPrimary.withValues(alpha: 0.1) 
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: recruiterPrimary,
                      width: 4.w,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            recruiterPrimary,
                            recruiterSecondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : recruiterPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: recruiterPrimary.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right_rounded,
                  color: recruiterPrimary,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

