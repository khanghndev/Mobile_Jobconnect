import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_string.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_screen.dart';
import 'package:job_connect/features/widgets/appbar_drawer.dart';
import 'package:job_connect/features/chat/screens/ai_chat_screen.dart';
import 'package:job_connect/features/home/screens/home_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_feed_screen.dart';
import 'package:job_connect/features/profile/screens/profile_screen.dart';
import 'package:job_connect/features/resume/screens/cv_options_screen.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'dart:ui'; // For ImageFilter

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const HomePage({super.key, this.isLoggedIn = false, required this.idUser});

  static final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();

  static void goToSearchTab(BuildContext context, {int? initialTabIndex}) {
    // // Thêm initialTabIndex
    // final state = context.findAncestorStateOfType<HomePageState>();
    // if (state == null || !state.mounted) {
    //   return;
    // }
    // const int targetIndex = 2;
    // final List<int> publicTabIndexes = [0, 4];
    // if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
    //   state._showLoginRequiredDialog();
    //   return;
    // }
    // // Truyền initialTabIndex (nếu có) xuống SearchScreen thông qua navigateToTab
    // state.navigateToTab(
    //   targetIndex,
    //   navigateToSavedInSearch: initialTabIndex == 2,
    //   searchInitialTab: initialTabIndex,
    // );
  }

  static void goToUniJobsTab(BuildContext context, {int? initialTabIndex}) {
    // Thêm initialTabIndex
    final state = context.findAncestorStateOfType<HomePageState>();
    if (state == null || !state.mounted) {
      return;
    }
    const int targetIndex = 2;
    final List<int> publicTabIndexes = [0, 4];
    if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
      state._showLoginRequiredDialog();
      return;
    }
    // Truyền initialTabIndex (nếu có) xuống SearchScreen thông qua navigateToTab
    state.navigateToTab(
      targetIndex,
      navigateToSavedInSearch: initialTabIndex == 2,
      searchInitialTab: initialTabIndex,
    );
  }

  // static void goToChatBotTab(BuildContext context) {
  //   final state = context.findAncestorStateOfType<HomePageState>();
  //   if (state == null || !state.mounted) return;
  //   const int targetIndex = 3;
  //   final List<int> publicTabIndexes = [0, 4];
  //   if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
  //     state._showLoginRequiredDialog();
  //     return;
  //   }
  //   state.navigateToTab(targetIndex);
  // }

  static void goToChatMessageTab(BuildContext context) {
    final state = context.findAncestorStateOfType<HomePageState>();
    if (state == null || !state.mounted) return;
    const int targetIndex = 3;
    final List<int> publicTabIndexes = [0, 4];
    if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
      state._showLoginRequiredDialog();
      return;
    }
    state.navigateToTab(targetIndex);
  }

  static void goToCVTab(BuildContext context) {
    final state = context.findAncestorStateOfType<HomePageState>();
    if (state == null || !state.mounted) return;
    const int targetIndex = 1;
    final List<int> publicTabIndexes = [0, 4];
    if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
      state._showLoginRequiredDialog();
      return;
    }
    state.navigateToTab(targetIndex);
  }

  static void goToProfileTab(BuildContext context) {
    final state = context.findAncestorStateOfType<HomePageState>();
    if (state == null || !state.mounted) {
      print(
        "[HomePage] goToProfileTab: HomePageState is not available or not mounted.",
      );
      return;
    }
    const int targetIndex = 4;
    final List<int> publicTabIndexes = [0, 4];
    if (!state.widget.isLoggedIn && !publicTabIndexes.contains(targetIndex)) {
      state._showLoginRequiredDialog();
      return;
    }
    state.navigateToTab(targetIndex);
  }

  static void goToSavedJobsTab(BuildContext context) {
    final state = context.findAncestorStateOfType<HomePageState>();
    if (state == null || !state.mounted) {
      print(
        "[HomePage] goToSavedJobsTab: HomePageState is not available or not mounted.",
      );
      return;
    }
    // Chuyển đến tab Search (index 2) và yêu cầu SearchScreen mở tab "Đã lưu" (index 2 của TabBar trong SearchScreen)
    state.navigateToTab(2, navigateToSavedInSearch: true, searchInitialTab: 2);
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<Widget> _screens = [];

  // Animation cho BottomNavBar
  late AnimationController _navBarAnimationController;
  late Animation<double> _navBarFadeAnimation;

  @override
  void initState() {
    super.initState();
    _navBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ), // Thời gian animation cho NavBar
    );
    _navBarFadeAnimation = CurvedAnimation(
      parent: _navBarAnimationController,
      curve: Curves.easeInOut,
    );
    _updateScreens();
    _navBarAnimationController.forward(); // Chạy animation khi initState
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoggedIn != oldWidget.isLoggedIn ||
        widget.idUser != oldWidget.idUser) {
      _updateScreens();
    }
  }

  // TODO: Cập nhập màn hình
  void _updateScreens() {
    // TODO: TRANG CHỦ
    final homeScreenWithAppBar = CustomAppBarWithDrawer(
      key: const ValueKey('HomeScreenWithAppBar'),
      isLoggedIn: widget.isLoggedIn,
      idUser: widget.idUser,
      title: AppStrings.appName,
      bodyBuilder: HomeScreen(
        key: const PageStorageKey('HomeScreenContent'),
        isLoggedIn: widget.isLoggedIn,
        idUser: widget.idUser,
      ),
    );
    // TODO: CV
    final cvOptionsScreenWithAppBar = CustomAppBarWithDrawer(
      key: const ValueKey('CVOptionsScreenWithAppBar'),
      isLoggedIn: widget.isLoggedIn,
      idUser: widget.idUser,
      title: AppStrings.appCV,
      bodyBuilder: CVOptionsScreen(
        key: const PageStorageKey('CVOptionsScreenContent'),
        isLoggedIn: widget.isLoggedIn,
        idUser: widget.idUser,
      ),
    );
    // TODO: TÌM KIẾM
    // final searchPageWithAppBar = CustomAppBarWithDrawer(
    //   key: const ValueKey('SearchPageWithAppBar'),
    //   isLoggedIn: widget.isLoggedIn,
    //   idUser: widget.idUser,
    //   bodyBuilder:
    //       (registerRefreshCallback) => SearchPage(
    //         // Truyền searchInitialTab
    //         key: PageStorageKey(
    //           'SearchPageContent_tab$_searchPageInitialTab',
    //         ), // Key khác nhau nếu tab khác nhau
    //         isLoggedIn: widget.isLoggedIn,
    //         idUser: widget.idUser,
    //         registerRefreshCallback: registerRefreshCallback,
    //         initialTabIndex: _searchPageInitialTab, // Truyền xuống SearchPage
    //       ),
    // );
    // TODO: MẠNG XÃ HỘI
    final socialScreenWithAppBar = CustomAppBarWithDrawer(
      key: const ValueKey('SocialScreenWithAppBar'),
      isLoggedIn: widget.isLoggedIn,
      idUser: widget.idUser,
      title: AppStrings.appSocial,
      bodyBuilder: SocialFeedScreen(
        key: const PageStorageKey('SocialScreenContent'),
        isLoggedIn: widget.isLoggedIn,
        idUser: widget.idUser,
      ),
    );
    // TODO: CHAT BOX AI
    // final chatScreenWithAppBar = CustomAppBarWithDrawer(
    //   key: const ValueKey('ChatScreenWithAppBar'),
    //   isLoggedIn: widget.isLoggedIn,
    //   idUser: widget.idUser,
    //   bodyBuilder:
    //       (registerRefreshCallback) => AIChatScreen(
    //         key: const PageStorageKey('ChatScreenContent'),
    //         isLoggedIn: widget.isLoggedIn,
    //         idUser: widget.idUser,
    //         registerRefreshCallback: registerRefreshCallback,
    //       ),
    // );

    // TODO: CHATBOX MESSAGER
    final chatMessageScreenWithAppBar = CustomAppBarWithDrawer(
      key: const ValueKey('ChatMessageScreenWithAppBar'),
      isLoggedIn: widget.isLoggedIn,
      idUser: widget.idUser,
      title: AppStrings.appMessage,
      bodyBuilder: SocialMessengerScreen(
        key: const PageStorageKey('ChatMessageScreenContent'),
        isLoggedIn: widget.isLoggedIn,
        idUser: widget.idUser,
      ),
    );

    // TODO: TRANG CÁ NHÂN
    final profilePageScreenWithAppBar = CustomAppBarWithDrawer(
      key: const ValueKey('ProfilePageScreenWithAppBar'),
      isLoggedIn: widget.isLoggedIn,
      idUser: widget.idUser,
      title: AppStrings.appProfile,
      bodyBuilder: ProfilePageScreen(
        key: const PageStorageKey('ProfilePageScreenContent'),
        isLoggedIn: widget.isLoggedIn,
        idUser: widget.idUser,
      ),
    );

    // TODO: THÊM MÀN MỚI CHỖ NÀY
    final newScreens = [
      homeScreenWithAppBar,
      cvOptionsScreenWithAppBar,
      // searchPageWithAppBar,
      socialScreenWithAppBar,
      // chatScreenWithAppBar,
      chatMessageScreenWithAppBar,
      profilePageScreenWithAppBar,
    ];
    if (mounted) setState(() => _screens = newScreens);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navBarAnimationController.dispose();
    super.dispose();
  }

  int _searchPageInitialTab = 0; // Biến để lưu tab ban đầu cho màn hình chính giữa

  void navigateToTab(
    int index, {
    bool navigateToSavedInSearch = false,
    int? searchInitialTab,
  }) {
    if (!mounted) return;
    if (index < 0 || index >= _screens.length) {
      print("navigateToTab: Invalid index: $index");
      return;
    }

    // Nếu là tab Search và có yêu cầu mở tab con cụ thể
    if (index == 2 && searchInitialTab != null) {
      setState(() {
        _searchPageInitialTab = searchInitialTab;
        // Cập nhật lại _screens để SearchPage nhận initialTabIndex mới
        // Điều này sẽ rebuild SearchPage với TabController được đặt đúng vị trí
        // Quan trọng: Cần đảm bảo SearchPage có tham số initialTabIndex và xử lý nó
      });
      _updateScreens(); // Rebuild screens để SearchPage nhận initialTabIndex mới
    }

    if (_currentIndex == index &&
        !navigateToSavedInSearch &&
        (index == 2 && searchInitialTab == null))
      return;

    _performPageJump(index);
  }

  void _performPageJump(int index) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(
        index,
      ); // Sử dụng jumpToPage để không có animation ngang
      if (mounted && _currentIndex != index) {
        setState(() => _currentIndex = index);
        _navBarAnimationController.forward(
          from: 0.0,
        ); // Chạy lại animation khi tab thay đổi
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          if (_currentIndex != index) {
            _pageController.jumpToPage(index);
            setState(() => _currentIndex = index);
            _navBarAnimationController.forward(from: 0.0);
          }
        }
      });
    }
  }

  void _onTabTapped(int index) {
    final List<int> publicTabIndexes = [0, 4];
    if (!widget.isLoggedIn && !publicTabIndexes.contains(index)) {
      _showLoginRequiredDialog();
      return;
    }
    navigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_screens.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            key: Key("empty_screens_indicator"),
            color: theme.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        key: const ValueKey('mainPageView'),
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Tắt cuộn ngang của PageView
        children: _screens,
        onPageChanged: (index) {
          // Vẫn giữ lại để cập nhật _currentIndex nếu cần
          if (mounted && _currentIndex != index) {
            setState(() => _currentIndex = index);
            _navBarAnimationController.forward(from: 0.0);
          }
        },
      ),
      bottomNavigationBar: FadeTransition(
        // Animation cho toàn bộ BottomNavBar
        opacity: _navBarFadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_navBarFadeAnimation),
          child: Container(
            height: 75, // Tăng chiều cao một chút
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 8,
            ), // Thêm margin top
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? const Color(0xFF2C2C2E)
                      : Colors.white, // Màu nền
              borderRadius: BorderRadius.circular(28), // Bo góc lớn hơn
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(isDarkMode ? 0.25 : 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              // Clip để hiệu ứng blur không tràn ra ngoài
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                // Hiệu ứng kính mờ (glassmorphism)
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  // Container này có thể có màu nền mờ nhẹ
                  color:
                      isDarkMode
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceAround, // SpaceAround để các item cách đều
                    children: [
                      _buildNavItem(
                        0,
                        Icons.home_outlined,
                        Icons.home_rounded,
                        'Trang Chủ',
                        theme,
                      ),
                      _buildNavItem(
                        1,
                        Icons.file_copy_outlined,
                        Icons.file_copy_rounded,
                        'CV',
                        theme,
                      ),
                      _buildNavItem(
                        2,
                        Icons.local_fire_department_rounded,
                        Icons.local_fire_department,
                        'UniJobs',
                        theme,
                        isSpecial: true,
                      ), 
                      // _buildNavItem(
                      //   3,
                      //   Icons.chat_bubble_outline_rounded,
                      //   Icons.chat_bubble_rounded,
                      //   'AI Chat',
                      //   theme,
                      // ),
                      _buildNavItem(
                        3,
                        Icons.chat_bubble_outline_rounded,
                        Icons.chat_bubble_rounded,
                        'Hộp thư',
                        theme,
                      ),
                      _buildNavItem(
                        4,
                        Icons.person_outline_rounded,
                        Icons.person_rounded,
                        'Cá Nhân',
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    ThemeData theme, {
    bool isSpecial = false,
  }) {
    final isSelected = _currentIndex == index;
    final Color selectedColor = theme.colorScheme.primary;
    final Color unselectedColor = theme.colorScheme.onSurfaceVariant
        .withOpacity(0.7);
    final Color specialSelectedColor =
        theme
            .colorScheme
            .onPrimary; // Màu cho icon/text của nút đặc biệt khi active
    final Color specialUnselectedColor =
        theme
            .colorScheme
            .onSecondaryContainer; // Màu cho icon/text của nút đặc biệt khi inactive

    if (isSpecial) {
      return Expanded(
        // Cho phép nút đặc biệt chiếm không gian linh hoạt hơn
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(20), // Bo góc cho hiệu ứng chạm
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut, // Hiệu ứng nảy
                width: isSelected ? 64 : 58, // Kích thước thay đổi khi chọn
                height: isSelected ? 42 : 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isSelected
                            ? [selectedColor, selectedColor.withOpacity(0.7)]
                            : [
                              theme.colorScheme.secondary,
                              theme.colorScheme.secondary.withOpacity(0.7),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16), // Bo góc lớn hơn
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected
                              ? selectedColor
                              : theme.colorScheme.secondary)
                          .withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isSelected
                      ? Icons.local_fire_department_outlined
                      : iconOutlined, // Icon khác khi active
                  color:
                      isSelected
                          ? specialSelectedColor
                          : specialUnselectedColor,
                  size: isSelected ? 26 : 24, // Kích thước icon thay đổi
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 10.5, // Font nhỏ hơn một chút
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              // Animation cho icon
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isSelected ? iconFilled : iconOutlined,
                key: ValueKey<bool>(
                  isSelected,
                ), // Key để AnimatedSwitcher nhận diện thay đổi
                color: isSelected ? selectedColor : unselectedColor,
                size: isSelected ? 26 : 23, // Kích thước icon thay đổi
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              // Animation cho text
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 10.5,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    // ... (Giữ nguyên dialog này, đảm bảo nó sử dụng Theme.of(context))
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: theme.cardColor,
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_person_outlined,
                              color: theme.colorScheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Yêu Cầu Đăng Nhập',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          Text(
                            'Để tiếp tục, bạn cần đăng nhập vào tài khoản ${AppStrings.appName}. Khám phá ngay!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, true);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: Text(
                                'ĐĂNG NHẬP NGAY',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'ĐỂ SAU',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
