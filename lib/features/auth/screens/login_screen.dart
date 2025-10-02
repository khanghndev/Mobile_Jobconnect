import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/dialog_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/auth/widgets/login/login_form.dart';
import 'package:job_connect/features/auth/widgets/login/social_login_view.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _showLoginForm = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onLogin(AuthViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    await vm.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return; 

    if (vm.errorMessage != null) {
      DialogUtils.showDialogMessage(
        context,
        message: vm.errorMessage!,
        title: "Thất bại",
        type: DialogType.error,
        buttonText: "Đóng",
      );
    } else if (vm.loginModel != null) {
      context.go('/home', extra: {
        'isLoggedIn': vm.isLoggedIn,
        'idUser': vm.loginModel!.user.idUser,
      });
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Đăng nhập thành công',
        backgroudColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
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
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: BackgroundColors.backgroundDefaultPrimary
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: BackgroundColors
                                    .backgroundDefaultPrimarySub
                                    .withValues(alpha: 0.2),
                                blurRadius: 20.r,
                                offset: Offset(0, 10.h),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: _showLoginForm
                                ? LoginForm(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    isLoading: vm.isLoading,
                                    onLogin: () => _onLogin(vm),
                                    onBack: () =>setState(() => _showLoginForm = false),
                                  )
                                : SocialLoginView(
                                    onShowTraditionalLogin: () => setState(
                                        () => _showLoginForm = true),
                                    onGoogleLogin: (_) => {}
                                  ),
                          ),
                        ),
                      ),
                    ),
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
