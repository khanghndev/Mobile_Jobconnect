import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/config/widgets/custom_dialog.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/auth/widgets/login/login_form.dart';
import 'package:job_connect/features/auth/widgets/login/social_login_view.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String? role;
  const LoginScreen({super.key, this.role = 'Candidate'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showLoginForm = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Đăng nhập bằng email & password
  Future<void> _onLogin(AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await authVM.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authVM.errorMessage != null) {
      CustomDialog.show(
        context,
        title: "Thất bại",
        message: authVM.errorMessage ?? "Đăng nhập thất bại.",
        icon: Icons.error_outline,
        iconColor: BackgroundColors.backgroundErrorPrimary,
        confirmButtonColor: BackgroundColors.backgroundErrorPrimary,
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
        confirmText: "Đồng ý",
      );
      return;
    }

    if (authVM.idUser != null) {
      final idUser = authVM.idUser!;
      final userVM = context.read<UserViewModel>();
      final notificationVM = context.read<NotificationViewModel>();

      await userVM.getCurrentUser(idUser);
      await notificationVM.getUnreadCount(idUser);

      final actualRole = userVM.roleName?.trim().toLowerCase();
      final expectedRole = (widget.role ?? UserRole.candidate.name).toLowerCase();

      if (actualRole != expectedRole) {
        if(mounted){
          CustomDialog.show(
            context,
            title: "Sai vai trò",
            message:"Vui lòng đăng nhập bằng cổng dành cho ${StringUtils.capitalize(expectedRole)}.",
            icon: Icons.warning_amber_outlined,
            iconColor: BackgroundColors.backgroundWarningPrimary,
            confirmButtonColor: BackgroundColors.backgroundWarningPrimary,
            backgroundColor: BackgroundColors.backgroundWarningPrimary,
            confirmText: "Đồng ý",
            onConfirm: () => context.push('/auth/role'),
          );
        }
        return;
      }

      if (actualRole == UserRole.candidate.name.toLowerCase()) {
        if(mounted){
          context.go('/home', extra: {
            'isLoggedIn': authVM.isLoggedIn,
            'idUser': idUser,
          });
        }
      } else if (actualRole == UserRole.recruiter.name.toLowerCase()) {
        if(mounted){
          context.go('/recruiter', extra: {
            'userAccount': userVM.currentUser,
            'isLoggedIn': authVM.isLoggedIn,
            'currentIndex': 0,
          });
        }
      }

      if(mounted){
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Đăng nhập thành công',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
        }
    }
  }

  /// Đăng nhập bằng Google 
  Future<void> _onLoginGoogle(AuthViewModel authVM) async {
    FocusScope.of(context).unfocus();

    await authVM.loginWithGoogle();

    if (!mounted) return;

    if (authVM.errorMessage != null) {
      CustomDialog.show(
        context,
        title: "Thất bại",
        message: authVM.errorMessage ?? "Đăng nhập Google thất bại.",
        icon: Icons.error_outline,
        iconColor: BackgroundColors.backgroundErrorPrimary,
        confirmButtonColor: BackgroundColors.backgroundErrorPrimary,
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
        confirmText: "Đồng ý",
      );
      return;
    }

    if (authVM.isSuccess && authVM.idUser != null) {
      final userVM = context.read<UserViewModel>();
      final notificationVM = context.read<NotificationViewModel>();

      await userVM.getCurrentUser(authVM.idUser!);
      await notificationVM.getUnreadCount(authVM.idUser!);

      if (!mounted) return;

      // Chuyển hướng đúng role
      final actualRole = userVM.roleName?.trim().toLowerCase();
      if (actualRole == UserRole.candidate.name.toLowerCase()) {
        context.go('/home', extra: {
          'isLoggedIn': authVM.isLoggedIn,
          'idUser': authVM.idUser,
        });
      } else if (actualRole == UserRole.recruiter.name.toLowerCase()) {
        context.go('/recruiter', extra: {
          'userAccount': userVM.currentUser,
          'isLoggedIn': authVM.isLoggedIn,
          'currentIndex': 0,
        });
      }

      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Đăng nhập Google thành công',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        return OverlayLoading(
          isLoading: authVM.isLoading,
          child: Scaffold(
            body: Container(
              width: 1.sw,
              height: 1.sh,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              child: UnfocusWidget(
                child: SafeArea(
                  child: Stack(
                    children: [
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      BackgroundColors.backgroundDefaultPrimary.withValues(alpha:0.9),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: BackgroundColors.backgroundDefaultPrimarySub
                                          .withValues(alpha:0.2),
                                      blurRadius: 20.r,
                                      offset: Offset(0, 10.h),
                                    ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(opacity: anim, child: child),
                                  child: _showLoginForm
                                      ? LoginForm(
                                          formKey: _formKey,
                                          emailController: _emailController,
                                          passwordController: _passwordController,
                                          isLoading: authVM.isLoading,
                                          onLogin: () => _onLogin(authVM),
                                          onBack: () =>
                                              setState(() => _showLoginForm = false),
                                          isRemmeber: false,
                                        )
                                      : SocialLoginView(
                                          role: widget.role ??
                                              StringUtils.capitalize(
                                                  UserRole.candidate.name),
                                          onShowTraditionalLogin: () =>
                                              setState(() => _showLoginForm = true),
                                          onGoogleLogin: (context) =>
                                              _onLoginGoogle(authVM),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withValues(alpha:0.25),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                                onPressed: () {
                                  if (_showLoginForm) {
                                    setState(() => _showLoginForm = false);
                                  } else {
                                    context.go('/auth/role');
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
