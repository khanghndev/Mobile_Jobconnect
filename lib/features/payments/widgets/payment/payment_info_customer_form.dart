import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/formatter_service.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';

class PaymentInfoCustomerForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  const PaymentInfoCustomerForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.formKey,
  });

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lấy dữ liệu từ UserViewModel
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.currentUser;
    nameController.text = user?.userName ?? '';
    phoneController.text = FormatUtils.formatPhoneNumber(user?.phoneNumber ?? '');
    emailController.text = user?.email ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: "Thông tin khách hàng",
                fontSize: 22.sp,
                icon: Icons.supervisor_account_sharp,
                iconColor: theme.iconTheme.color
              ),
              SizedBox(height: 20.h),
              CustomTextFieldWithLabel(
                controller: nameController,
                label: 'Họ và tên',
                icon: Icons.person_outline,
                validator: (value) => InputValidators.validate(
                  value: value,
                  hintText: 'Họ và tên',
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextFieldWithLabel(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                hintText: 'Nhập số điện thoại',
                label: 'Số điện thoại',
                icon: Icons.phone,
                fillColor: BackgroundColors.backgroundInputFieldDefault,
                inputFormatters: [FormatterService.phoneFormatter],
                contentPadding: EdgeInsets.all(16.w),
                borderColor: BorderColors.borderInputFieldDefault,
                validator: (value) => InputValidators.validate(
                  value: value,
                  hintText: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextFieldWithLabel(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => InputValidators.validate(
                  value: value,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}