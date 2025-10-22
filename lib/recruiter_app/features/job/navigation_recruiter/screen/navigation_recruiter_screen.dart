import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/features/mini_social/screens/home/social_feed_screen.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/recruiter_app/features/hr/screens/hr_home_screen.dart';
import 'package:job_connect/recruiter_app/features/post/screens/hr_post_job_screen.dart';
import 'package:job_connect/recruiter_app/features/profile/screens/hr_profile_screen.dart';
import 'package:job_connect/recruiter_app/features/search/screens/hr_search_screen.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/widget/bottom_nav_bar.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/model_ui/tab_item_data.dart';

class NavigationRecruiterScreen extends StatefulWidget {
  final bool isLoggedIn;
  final UserModel userAccount;
  final int currentIndex;

  const NavigationRecruiterScreen({
    super.key,
    required this.isLoggedIn,
    required this.userAccount,
    this.currentIndex = 0,
  });

  @override
  State<NavigationRecruiterScreen> createState() =>
      _NavigationRecruiterScreenState();
}

class _NavigationRecruiterScreenState extends State<NavigationRecruiterScreen> {
  late int _currentIndex;
  late final PageController _pageController;
  late final List<Widget> _screens;
  late final List<TabItemData> _tabItems;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _tabItems = [
      TabItemData(
        screen: HRHomeScreen(
          key: PageStorageKey('HRHomeScreen'),
          userAccount: widget.userAccount,
        ),
        iconOutlined: Icons.home_outlined,
        iconFilled: Icons.home_rounded,
        label: 'Home',
      ),
      TabItemData(
        screen: SearchHrScreen(
          key: PageStorageKey('SearchHrScreen_${widget.userAccount.idUser}'),
          recruiterId: widget.userAccount.idUser,
        ),
        iconOutlined: Icons.explore_outlined,
        iconFilled: Icons.explore,
        label: 'Explore',
      ),
      TabItemData(
        screen: SocialFeedScreen(
          key: PageStorageKey('SocialFeedScreen${widget.userAccount.idUser}'),
          isLoggedIn: widget.isLoggedIn,
          idUser: widget.userAccount.idUser,
        ),
        
        iconOutlined: Icons.local_fire_department_rounded,
        iconFilled: Icons.local_fire_department,
        label: AppStrings.appName,
        isSpecial: true,
      ),
      TabItemData(
        screen: PostJobPage(
          key: PageStorageKey('PostJobPage_${widget.userAccount.idUser}'),
          recruiterId: widget.userAccount.idUser,
        ),
        iconOutlined: Icons.camera_alt_outlined,
        iconFilled: Icons.camera_alt_outlined,
        label: 'Post',
      ),
      TabItemData(
        screen: RecruiterProfilePage(
          key: PageStorageKey('RecruiterProfilePage_${widget.userAccount.idUser}'),
          recruiterId: widget.userAccount.idUser,
          account: widget.userAccount,
        ),
        iconOutlined: Icons.person_outline_rounded,
        iconFilled: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    _screens = _tabItems.map((e) => e.screen).toList();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _currentIndex = widget.currentIndex;
  //   _pageController = PageController(initialPage: _currentIndex);

  //   _tabItems = [
  //     TabItemData(
  //       screen: CustomAppBarWithDrawer(
  //         isLoggedIn: widget.isLoggedIn,
  //         idUser: widget.userAccount.idUser,
  //         title: 'Trang chủ',
  //         bodyBuilder: HRHomeScreen(
  //           key: PageStorageKey('HRHomeScreen'),
  //           userAccount: widget.userAccount,
  //         ),
  //           drawer: DrawerRecruiterSection( 
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //       ),
  //       iconOutlined: Icons.home_outlined,
  //       iconFilled: Icons.home_rounded,
  //       label: 'Homes',
  //     ),
  //     TabItemData(
  //       screen: CustomAppBarWithDrawer(
  //         isLoggedIn: widget.isLoggedIn,
  //         idUser: widget.userAccount.idUser,
  //         title: 'Tìm kiếm',
  //         bodyBuilder: SearchHrScreen(
  //           key: PageStorageKey('SearchHrScreen_${widget.userAccount.idUser}'),
  //           recruiterId: widget.userAccount.idUser,
  //         ),
  //         drawer: DrawerRecruiterSection( 
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //       ),
  //       iconOutlined: Icons.explore_outlined,
  //       iconFilled: Icons.explore,
  //       label: 'Explore',
  //     ),
  //     TabItemData(
  //       screen: CustomAppBarWithDrawer(
  //         isLoggedIn: widget.isLoggedIn,
  //         idUser: widget.userAccount.idUser,
  //         title: AppStrings.appName,
  //         bodyBuilder: SocialFeedScreen(
  //           key: PageStorageKey('SocialFeedScreen${widget.userAccount.idUser}'),
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //         drawer: DrawerRecruiterSection( 
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //       ),
  //       iconOutlined: Icons.local_fire_department_rounded,
  //       iconFilled: Icons.local_fire_department,
  //       label: AppStrings.appName,
  //       isSpecial: true,
  //     ),
  //     TabItemData(
  //       screen: CustomAppBarWithDrawer(
  //         isLoggedIn: widget.isLoggedIn,
  //         idUser: widget.userAccount.idUser,
  //         title: 'Đăng tin',
  //         bodyBuilder: PostJobPage(
  //           key: PageStorageKey('PostJobPage_${widget.userAccount.idUser}'),
  //           recruiterId: widget.userAccount.idUser,
  //         ),
  //         drawer: DrawerRecruiterSection( 
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //       ),
  //       iconOutlined: Icons.camera_alt_outlined,
  //       iconFilled: Icons.camera_alt_outlined,
  //       label: 'Post',
  //     ),
  //     TabItemData(
  //       screen: CustomAppBarWithDrawer(
  //         isLoggedIn: widget.isLoggedIn,
  //         idUser: widget.userAccount.idUser,
  //         title: 'Hồ sơ',
  //         bodyBuilder: RecruiterProfilePage(
  //           key: PageStorageKey('RecruiterProfilePage_${widget.userAccount.idUser}'),
  //           recruiterId: widget.userAccount.idUser,
  //           account: widget.userAccount,
  //         ),
  //         drawer: DrawerRecruiterSection( 
  //           isLoggedIn: widget.isLoggedIn,
  //           idUser: widget.userAccount.idUser,
  //         ),
  //       ),
  //       iconOutlined: Icons.person_outline_rounded,
  //       iconFilled: Icons.person_rounded,
  //       label: 'Profile',
  //     ),
  //   ];

  //   _screens = _tabItems.map((e) => e.screen).toList();
  // }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override

  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        tabItems: _tabItems,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}