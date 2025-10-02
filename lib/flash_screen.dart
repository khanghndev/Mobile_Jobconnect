import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  // Cập nhật constructor để nhận isLoggedIn và idUser
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

  bool _showLoginOptions = false;
  bool _showIntroduction = false;
  int _currentIntroPage = 0;

  final List<Map<String, dynamic>> _introContent = [
    {
      'title': 'Tìm kiếm công việc mơ ước',
      'subtitle':
          'Khám phá hàng ngàn cơ hội việc làm phù hợp với kỹ năng của bạn',
      'icon': Icons.search,
    },
    {
      'title': 'Kết nối với nhà tuyển dụng',
      'subtitle': 'Tương tác trực tiếp và xây dựng mạng lưới chuyên nghiệp',
      'icon': Icons.handshake,
    },
    {
      'title': 'Phát triển sự nghiệp',
      'subtitle':
          'Công cụ và nguồn lực để nâng cao kỹ năng và đạt được mục tiêu',
      'icon': Icons.trending_up,
    },
  ];

  final PageController _pageController = PageController();
  Timer? _introTimer; // Khai báo Timer để có thể hủy nó

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _animationController.forward();

    // Hiển thị logo trước, sau đó hiển thị phần giới thiệu
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showIntroduction = true;
      });

      // Tự động chuyển trang giới thiệu
      _introTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_currentIntroPage < _introContent.length - 1) {
          _currentIntroPage++;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentIntroPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        } else if (!_showLoginOptions) {
          timer.cancel();
          setState(() {
            _showLoginOptions = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _introTimer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _skipIntroAndShowLogin() {
    _introTimer?.cancel(); // Hủy timer khi người dùng bỏ qua
    setState(() {
      _showLoginOptions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1), // Deep blue
              const Color(0xFF1976D2), // Blue
              Theme.of(context).colorScheme.primary.withValues(alpha:
                0.9,
              ), // Light blue (using theme)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height:
                    _showIntroduction ? size.height * 0.25 : size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo với hiệu ứng phóng to
                    ScaleTransition(
                      scale: _animation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .surface, // Sử dụng màu surface từ theme
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha:0.15),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            'assets/images/logohuit.png',
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 70,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tên ứng dụng với hiệu ứng làm mờ
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            "Huitworks",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: const [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kết nối tài năng, khai phá cơ hội",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Phần giới thiệu các tính năng
              if (_showIntroduction && !_showLoginOptions)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentIntroPage = page;
                            });
                          },
                          itemCount: _introContent.length,
                          itemBuilder: (context, index) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _introContent[index]['icon'],
                                      size: 80,
                                      color: Colors.white.withValues(alpha:
                                        0.9,
                                      ), // Giữ nguyên trắng trong suốt trên nền xanh
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      _introContent[index]['title'],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _introContent[index]['subtitle'],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withValues(alpha:0.9),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Chỉ báo trang hiện tại và nút bỏ qua
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Chỉ báo trang
                            Row(
                              children: List.generate(
                                _introContent.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  width:
                                      _currentIntroPage == index ? 24.0 : 8.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentIntroPage == index
                                            ? Colors.white
                                            : Colors.white.withValues(alpha:0.4),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                              ),
                            ),

                            // Khoảng cách
                            const SizedBox(width: 40),

                            // Nút bỏ qua
                            TextButton(
                              onPressed: _skipIntroAndShowLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                "BỎ QUA",
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Phần hiển thị các nút đăng nhập, đăng ký
              if (_showLoginOptions)
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.0, 1.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      children: [
                        // Thông điệp giới thiệu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Text(
                            "Huitworks giúp bạn kết nối với cơ hội việc làm phù hợp và phát triển sự nghiệp trong môi trường chuyên nghiệp",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha:0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Nút đăng nhập
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context)
                                      .colorScheme
                                      .primary, // Lấy màu primary từ theme
                              backgroundColor:
                                  Theme.of(context)
                                      .colorScheme
                                      .onPrimary, // Lấy màu onPrimary từ theme (trắng)
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              "ĐĂNG NHẬP / ĐĂNG KÝ",
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                color:
                                    Theme.of(context)
                                        .colorScheme
                                        .primary, // Màu chữ trên nền nút
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Phần footer
                        Text(
                          "Phiên bản 1.0.0",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withValues(alpha:0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Hiển thị loading khi không có nội dung khác
              if (!_showIntroduction &&
                  !_showLoginOptions) // Chỉ hiển thị nếu chưa đăng nhập
                const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
