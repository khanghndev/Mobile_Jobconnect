import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/info_chip.dart';

class BadgesInfo extends StatelessWidget {
  final List<String> badges;

  const BadgesInfo({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: badges
            .map(
              (b) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InfoChip(
                  label: b,
                  color: Theme.of(context).colorScheme.primary,
                  isHighlighted: true,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}