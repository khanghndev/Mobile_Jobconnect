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
  final bool isRecruiter;

  const CustomAppBarWithDrawer({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.bodyBuilder,
    this.title = AppStrings.appName,
    required this.drawer,
    this.isRecruiter = false,
  });

  @override
  State<CustomAppBarWithDrawer> createState() => _CustomAppBarWithDrawerState();
}

class _CustomAppBarWithDrawerState extends State<CustomAppBarWithDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);
    final primaryColor = widget.isRecruiter ? recruiterPrimary : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64.h,
        leading: Builder(
          builder: (context) => Container(
            margin: EdgeInsets.only(left: 8.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: primaryColor,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationIcon(
            idUser: widget.idUser,
            isLoggedIn: widget.isLoggedIn,
            isRecruiter: widget.isRecruiter,
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => NavigationPage.goToProfileTab(context),
            child: const ProfileAvatar(),
          ),
          SizedBox(width: 12.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            height: 1.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primaryColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: widget.drawer,
      body: widget.bodyBuilder,
    );
  }
}