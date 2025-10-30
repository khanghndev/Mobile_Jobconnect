import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/home/screens/home_screen.dart';
import 'package:job_connect/features/mini_social/screens/home/social_feed_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_screen.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/custom_appbar_with_drawer.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_candidate_section.dart';
import 'package:job_connect/features/navigation/widgets/navigation/nav_bottom_bar.dart';
import 'package:job_connect/features/profile/screens/profile_screen.dart';
import 'package:job_connect/features/resume/screens/cv_options_screen.dart';
import 'package:job_connect/features/search/screens/search_screen.dart';

class NavigationPage extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const NavigationPage({
    super.key,
    this.isLoggedIn = false,
    required this.idUser,
  });

  static void _navigate(BuildContext context, int index, {int? searchTab, bool savedInSearch = false}) {
    final state = context.findAncestorStateOfType<NavigationPageState>();
    if (state == null || !state.mounted) return;

    const publicTabs = [0, 4];
    if (!state.widget.isLoggedIn && !publicTabs.contains(index)) {
      LoginRequiredDialog();
      return;
    }

    state.navigateToTab(index,
        navigateToSavedInSearch: savedInSearch, searchInitialTab: searchTab);
  }

  static void goToUniJobsTab(BuildContext context, {int? initialTabIndex}) => _navigate(context, 2, searchTab: initialTabIndex, savedInSearch: initialTabIndex == 2);
  static void goToChatMessageTab(BuildContext context) => _navigate(context, 3);
  static void goToCVTab(BuildContext context) => _navigate(context, 1);
  static void goToProfileTab(BuildContext context) => _navigate(context, 4);
  static void goToSavedJobsTab(BuildContext context) => _navigate(context, 2, searchTab: 2, savedInSearch: true);

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _navBarController;
  late Animation<double> _fadeAnimation;
  List<Widget> _screens = [];
  final List<String> routes = [
    '/home',
    '/resume/analysis',
    '/social/job-board',
    '/social/messages',
    '/social/profile',
  ];

  @override
  void initState() {
    super.initState();
    _navBarController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _navBarController, curve: Curves.easeInOut);
    _updateScreens();
    _navBarController.forward();
  }

  @override
  void didUpdateWidget(covariant NavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoggedIn != oldWidget.isLoggedIn || widget.idUser != oldWidget.idUser) {
      _updateScreens();
    }
  }

  void _onSearch(){
    context.push(
      '/home/search', 
      extra: {
        'isLoggedIn': widget.isLoggedIn,
        'idUser': widget.idUser,
        'initialTabIndex' : 1,
      }
    );
  }

  void _updateScreens() {
    final args = (
      loggedIn: widget.isLoggedIn,
      userId: widget.idUser,
    );

    final List<Widget> bodies = [
      HomeScreen(isLoggedIn: args.loggedIn, idUser: args.userId),
      // CVOptionsScreen(isLoggedIn: args.loggedIn, idUser: args.userId),
      SearchPage(idUser: args.userId, isLoggedIn: args.loggedIn),
      SocialFeedScreen(isLoggedIn: args.loggedIn, idUser: args.userId, onSearch: _onSearch,),
      SocialMessengerScreen(isLoggedIn: args.loggedIn, idUser: args.userId),
      ProfilePageScreen(isLoggedIn: args.loggedIn, idUser: args.userId),
    ];

    final List<String> titles = [
      AppStrings.appName,
      // AppStrings.appCV,
      AppStrings.search,
      AppStrings.appSocial,
      AppStrings.appMessage,
      AppStrings.appProfile,
    ];

    final newScreens = List.generate(routes.length, (index) {
      return CustomAppBarWithDrawer(
        isLoggedIn: args.loggedIn,
        idUser: args.userId,
        title: titles[index],
        bodyBuilder: bodies[index],
        drawer: DrawerCandidateSection(
          isLoggedIn: widget.isLoggedIn,
          idUser: widget.idUser,
          selectedRoute: routes[index], 
        ),
      );
    });

    if (mounted) setState(() => _screens = newScreens);
  }

  void navigateToTab(int index,{bool navigateToSavedInSearch = false, int? searchInitialTab}) {
    if (!mounted || index < 0 || index >= _screens.length) return;

    if (index == 2 && searchInitialTab != null) {
      _updateScreens();
    }

    if (_currentIndex == index && !navigateToSavedInSearch) return;
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
    _navBarController.forward(from: 0);
  }

  void _onTabTapped(int index) {
    const publicTabs = [0, 4];
    if (!widget.isLoggedIn && !publicTabs.contains(index)) {
      LoginRequiredDialog();
      return;
    }
    navigateToTab(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
            _navBarController.forward(from: 0);
          }
        },
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(_fadeAnimation),
          child: NavBottomBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}