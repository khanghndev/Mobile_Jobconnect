import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';

class SelectGroupBottomSheet extends StatelessWidget {
  final List<SocialGroupsModel> groups;
  final ValueChanged<Map<String, String>?> onSelect;

  const SelectGroupBottomSheet({
    super.key,
    required this.groups,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chọn nhóm để đăng bài',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),

          // Giới hạn chiều cao + scroll khi list dài
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    color: colorScheme.surface.withValues(alpha: 0.5),
                    margin: EdgeInsets.symmetric(vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      leading: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: colorScheme.primary),
                      ),
                      title: Text(
                        'Đăng lên trang cá nhân',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        onSelect(null);
                        context.pop();
                      },
                    ),
                  );
                }

                final g = groups[index - 1];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: ImageUtils.getImageProvider(g.avatarUrl),
                    ),
                    title: Text(
                      g.groupName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      onSelect({'id': g.idGroup, 'name': g.groupName});
                      context.pop();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}