import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/notification_icon.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';

class CustomAppBarWithDrawer extends StatefulWidget {
  final Widget bodyBuilder;
  final bool isLoggedIn;
  final String idUser;
  final String title;
  final Widget drawer; 

  const CustomAppBarWithDrawer({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.bodyBuilder,
    this.title = AppStrings.appName,
    required this.drawer, 
  });

  @override
  State<CustomAppBarWithDrawer> createState() => _CustomAppBarWithDrawerState();
}

class _CustomAppBarWithDrawerState extends State<CustomAppBarWithDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        toolbarHeight: 60.h,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5.h),
          child: Divider(height: 1.h, color: Colors.grey.shade300),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_open_rounded,
                color: theme.colorScheme.onSurface, size: 28.sp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationIcon(idUser: widget.idUser, isLoggedIn: widget.isLoggedIn),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => NavigationPage.goToProfileTab(context),
            child: const ProfileAvatar(),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      drawer: widget.drawer,
      body: widget.bodyBuilder,
    );
  }
}