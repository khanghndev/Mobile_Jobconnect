import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/config/widgets/info_chip.dart';

class FeaturedSkillTrendingList extends StatelessWidget {
  final List<String> skills;
  final void Function(String skill)? onSkillTap;
  final int maxItems;

  const FeaturedSkillTrendingList({
    super.key,
    required this.skills,
    this.onSkillTap,
    this.maxItems = 5,
  });

  static const List<Color> chipColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.redAccent,
    Colors.indigo,
    Colors.deepOrange,
  ];

  Color getRandomColor(int index) {
    return chipColors[index % chipColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (skills.isEmpty) {
      return Center(
        child: Text(
          'Kỹ năng sắp ra mắt!',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final displayedSkills =
        skills.length > maxItems ? skills.sublist(0, maxItems) : skills;

    return SizedBox(
      height: 50.h,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayedSkills.length,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final skill = displayedSkills[index];
            final chipColor = getRandomColor(index);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w), // Khoảng cách giữa các chip
                    child: GestureDetector(
                      onTap: () => onSkillTap?.call(skill),
                      child: InfoChip(
                        label: skill,
                        color: chipColor,
                        isHighlighted: true,
                        icon: Icons.star_rounded,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
