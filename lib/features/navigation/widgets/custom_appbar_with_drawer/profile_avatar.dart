import 'package:flutter/material.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_avatar_breathing.dart';

class ProfileAvatar extends StatelessWidget {
  final double? radius;
  const ProfileAvatar({super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<UserViewModel, String?>(
      selector: (_, vm) => vm.currentUser?.avatarUrl,
      builder: (context, avatarUrl, _) {
        return ProfileAvatarBreathing(
          radius: radius ?? 16.r,
          backgroundImage: ImageUtils.getImageProvider(avatarUrl),
          borderColors: [
            theme.colorScheme.secondary,
            theme.colorScheme.tertiary,
            theme.colorScheme.primary,
          ],
        );
      },
    );
  }
}
