import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final String? avatarUrl;
  final VoidCallback onPickImage;

  const ProfileImagePicker({
    super.key,
    required this.profileImage,
    required this.avatarUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130.w, 
                  height: 130.h, 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withValues(alpha: 0.3),
                        theme.colorScheme.secondary.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 60.r, // scaled radius
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : (avatarUrl != null && avatarUrl!.isNotEmpty)
                          ? ImageUtils.getImageProvider(avatarUrl!)
                          : null as ImageProvider?,
                  child: (profileImage == null &&
                          (avatarUrl == null || avatarUrl!.isEmpty))
                      ? Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 60.r,
                          color: theme.primaryColor.withValues(alpha: 0.6),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      padding: EdgeInsets.all(8.w), 
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5.w),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20.r, // scaled icon
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: onPickImage,
            icon: Icon(
              Icons.photo_library_outlined,
              color: theme.primaryColor,
              size: 20.r, 
            ),
            label: Text(
              "Thay đổi ảnh đại diện",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
