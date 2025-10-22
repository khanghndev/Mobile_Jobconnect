import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_section_card.dart';

class ProfileSkillsSection extends StatelessWidget {
  final List<String> skills;

  const ProfileSkillsSection({
    super.key,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (skills.isEmpty) {
      return ProfileSectionCard(
        title: "Kỹ Năng",
        titleIcon: Icons.flare_outlined,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              "Hãy cập nhật kỹ năng để nhà tuyển dụng tìm thấy bạn!",
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    }

    return ProfileSectionCard(
      title: "Kỹ Năng",
      titleIcon: Icons.flare_outlined,
      children: [
        AnimationLimiter(
          child: Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 400),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 40.h,
                child: FadeInAnimation(curve: Curves.easeOut, child: widget),
              ),
              children: skills.map((skill) {
                return Chip(
                  avatar: Icon(
                    Icons.star_border_rounded,
                    color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                    size: 18.sp,
                  ),
                  label: Text(
                    skill,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.8),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: theme.colorScheme.secondaryContainer,
                      width: 1.w,
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
