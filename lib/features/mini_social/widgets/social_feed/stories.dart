import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/features/mini_social/screens/social_feed_screen.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/story_viewer.dart';

class Stories extends StatelessWidget {
  final List<Story> stories;
  const Stories({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewer(
                    stories: stories, // danh sách Story
                    initialIndex: index, // story bấm vào
                  ),
                ),
              );
            },
            child: Container(
              width: 110.w,
              margin: EdgeInsets.only(right: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.asset(
                          story.imageUrl,
                          height: 160.h,
                          width: 110.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (story.isDraft)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Tạo tin',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: TextColors.textBrandOnbrand,
                                  ),
                            ),
                          ),
                        ),
                      if (story.isDraft)
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.r,
                            child: Icon(Icons.add,
                                color: Colors.blue, size: 18.sp),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    story.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: TextColors.textDefaultPrimary,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
