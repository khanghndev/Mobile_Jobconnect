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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          value: jobPostings.toString(),
          label: "Tin tuyển dụng",
          color: Colors.blue,
        ),
        _VerticalDividerCustom(),
        _StatItem(
          value: jobApplications.toString(),
          label: "Hồ sơ đã nhận",
          color: Colors.green,
        ),
        _VerticalDividerCustom(),
        _StatItem(
          value: positionsHired.toString(),
          label: "Vị trí đã tuyển",
          color: Colors.orange,
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
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: const Color(0xFF666666),
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
      height: 40.h,
      width: 1.w,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}