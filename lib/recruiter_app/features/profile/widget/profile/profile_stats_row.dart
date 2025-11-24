import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatsRow extends StatelessWidget {
  final int jobPostings;
  final int jobApplications;
  final int positionsHired;

  const ProfileStatsRow({
    super.key,
    required this.jobPostings,
    required this.jobApplications,
    required this.positionsHired,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _StatItem(
            value: jobPostings.toString(),
            label: "Tin tuyển dụng",
            color: recruiterPrimary,
          ),
        ),
        _VerticalDividerCustom(),
        Expanded(
          child: _StatItem(
            value: jobApplications.toString(),
            label: "Hồ sơ đã nhận",
            color: const Color(0xFF10B981),
          ),
        ),
        _VerticalDividerCustom(),
        Expanded(
          child: _StatItem(
            value: positionsHired.toString(),
            label: "Vị trí đã tuyển",
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _VerticalDividerCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF1A237E).withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}