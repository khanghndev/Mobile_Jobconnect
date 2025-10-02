import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/reset_method.dart';
import 'package:job_connect/config/utils/formatter_service.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_appbar.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/features/auth/screens/enter_otp_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  bool _isLoading = false;

  ResetMethod _selectedMethod = ResetMethod.email;
  late TabController _tabController;
  String _selectedCountryCode = '+84';
  final String title = 'Đặt lại mật khẩu'; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedMethod =
            _tabController.index == 0 ? ResetMethod.email : ResetMethod.phone;
      });
    });
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _phoneCon.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    String? email;
    String? phone;

    if (_selectedMethod == ResetMethod.email) {
      // Nếu chọn email, lấy email
      if (_emailCon.text.trim().isNotEmpty) {
        email = _emailCon.text.trim();
      }
    } else {
      // Nếu chọn phone, lấy phone
      if (_phoneCon.text.trim().isNotEmpty) {
        phone = _phoneCon.text.trim();
      }
    }

    // Chuyển sang màn hình OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterOtpPage(
          email: email ?? phone ?? '', // Ưu tiên email, nếu null lấy phone
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        automaticallyImplyLeading: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: TextColors.textBrandOnbrand,
          ),
        ),
        leading: CustomAdaptiveTapEffect(
          isOpacity: true,
          onPressed: () => context.pop(),
          child: Icon(
            getAdaptiveBackIcon(context),
            size: 22.sp,
            color: IconColors.iconBrandOnbrand,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                20.verticalSpace,
                // Icon
                CircleAvatar(
                  radius: 45.r,
                  backgroundColor: BackgroundColors.backgroundBrandPrimary,
                  child: Icon(
                    Icons.lock_reset,
                    size: 50.sp,
                    color: IconColors.iconBrandOnbrand,
                  ),
                ),
                30.verticalSpace,
                Text(
                  'Quên mật khẩu?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: TextColors.textBrandPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.verticalSpace,
                Text(
                  'Đừng lo lắng! Hãy chọn phương thức bên dưới để đặt lại mật khẩu của bạn.',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                35.verticalSpace,

                Container(
                  decoration: BoxDecoration(
                    color: BackgroundColors.backgroundDefaultPrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent, 
                    indicatorWeight: 0,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: BackgroundColors.backgroundDefaultPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.1),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: TextColors.textDefaultPrimary,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                    ),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: const [
                      Tab(text: 'Email'),
                      Tab(text: 'Số điện thoại'),
                    ],
                  ),
                ),

                30.verticalSpace,

                SizedBox(
                  height: _selectedMethod == ResetMethod.email ? 90.h : 100.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Email
                      CustomInputField(
                        controller: _emailCon,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Nhập email của bạn',
                        prefixIcon: const Icon(Icons.email_outlined),
                        contentPadding: EdgeInsets.all(16.w),
                        validator: (value) => InputValidators.validate(
                          value: value,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      // Phone
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.01),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3)
                              ),
                            ),
                            child: CountryCodePicker(
                              onChanged: (countryCode) {
                                setState(() {
                                  _selectedCountryCode =
                                      countryCode.dialCode ?? '+84';
                                });
                              },
                              initialSelection: 'VN',
                              favorite: const [
                                'VN','US','CN','JP','KR','SG','TH',
                              ],
                              flagWidth: 20.w,
                              padding: EdgeInsets.zero,
                              showDropDownButton: true,
                              dialogSize: Size(
                                MediaQuery.of(context).size.width * 0.9,
                                MediaQuery.of(context).size.height * 0.6,
                              ),
                              searchDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                hintText: 'Tìm quốc gia',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              dialogTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              boxDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: BackgroundColors.backgroundDefaultPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.1),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 5.h),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: CustomInputField(
                              controller: _phoneCon,
                              keyboardType: TextInputType.phone,
                              hintText: 'Nhập số điện thoại',
                              prefixIcon: const Icon(Icons.phone),
                              fillColor: Colors.grey.shade50,
                              inputFormatters: [
                                FormatterService.phoneFormatter
                              ],
                              contentPadding: EdgeInsets.all(16.w),
                              validator: (value) => InputValidators.validate(
                                value: value,
                                hintText: 'Số điện thoại',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                40.verticalSpace,

                Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: BackgroundColors.backgroundBrandPrimary.withValues(alpha: 0.4),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: BackgroundColors.backgroundDefaultPrimary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'TIẾP TỤC',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: TextColors.textBrandOnbrand,
                          ),
                        ),
                  ),
                ),

                24.verticalSpace,

                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back, size: 18.sp),
                  label: Text(
                    'Quay lại đăng nhập',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textBrandPrimary,
                    ),
                  ),
                ),

                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
