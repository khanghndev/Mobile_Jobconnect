import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';

class HrEditProfileScreen extends StatefulWidget {
  final UserModel account;
  final CompanyModel company;
  final RecruiterInfoModel recruiterInfo;

  const HrEditProfileScreen({
    super.key,
    required this.account,
    required this.company,
    required this.recruiterInfo,
  });

  @override
  _HrEditProfileScreenState createState() => _HrEditProfileScreenState();
}

class _HrEditProfileScreenState extends State<HrEditProfileScreen> {
  // Services
  RecruiterService recruiterService = RecruiterService();
  UserService accountService = UserService();
  CompanyService companyService = CompanyService();

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyScaleController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyLogoUrlController = TextEditingController();
  final _companyIndustryController = TextEditingController();
  final _companyLocationController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.userName;
    _emailController.text = widget.account.email;
    _phoneController.text = widget.account.phoneNumber ?? '';
    _locationController.text = widget.account.address ?? '';
    _companyNameController.text = widget.company.companyName;
    _companyScaleController.text = widget.company.scale;
    _companyWebsiteController.text = widget.company.websiteUrl ?? '';
    _companyDescriptionController.text = widget.company.description ?? '';
    _companyLogoUrlController.text = widget.company.logoCompany ?? '';
    _companyIndustryController.text = widget.company.industry;
    _companyLocationController.text = widget.company.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _companyNameController.dispose();
    _companyScaleController.dispose();
    _companyWebsiteController.dispose();
    _companyLocationController.dispose();
    _companyLogoUrlController.dispose();
    _companyIndustryController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh')),
      );
    }
  }

  // Cập nhật lại thông tin
  Future<void> _updateCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Cập nhật thông tin 
      final updatedAccount = UserModel(
        idUser: widget.account.idUser,
        userName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: widget.account.password,
        idRole: widget.account.idRole,
        accountStatus: widget.account.accountStatus,
        avatarUrl: widget.account.avatarUrl,
        socialLogin: widget.account.socialLogin,
        createdAt: widget.account.createdAt,
        updatedAt: DateTime.now(),
        gender: widget.account.gender,
        dateOfBirth: widget.account.dateOfBirth,
        address: _locationController.text,
        role: widget.account.role,
      );
      await accountService.updateUser(user: updatedAccount);

      // Cập nhật thông tin công ty
      final updated = CompanyModel(
        idCompany: widget.company.idCompany,
        companyName: _companyNameController.text,
        address: _companyLocationController.text,
        description: _companyDescriptionController.text,   
        logoCompany: _companyLogoUrlController.text,        
        websiteUrl: _companyWebsiteController.text,
        scale: _companyScaleController.text,
        industry: _companyIndustryController.text,
        status: widget.company.status,
        isFeatured: widget.company.isFeatured,
      );
      await companyService.updateCompany(company: updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayLoading(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppbarTitleLarge(title: "Chỉnh sửa hồ sơ"),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : UnfocusWidget(
              child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Ảnh đại diện
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : ImageUtils.getImageProvider(
                                        widget.account.avatarUrl != null &&
                                                widget.account.avatarUrl!.isNotEmpty
                                            ? widget.account.avatarUrl!
                                            : AppImages.defaultAvatar,
                                      ),
                              ),
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
              
                          // Thông tin cá nhân
                          const SectionTitle(
                            title: "THÔNG TIN CÁ NHÂN",
                            icon: Icons.person_pin_rounded,
                            fontSize: 16,
                          ),
                          const SizedBox(height: 16),
              
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _nameController,
                            label: 'Họ và tên',
                            hintText: 'Nhập họ và tên của bạn',
                            icon: Icons.person_outline,
                            validator: (value) => InputValidators.validate(
                              value: value,
                              hintText: 'Họ và tên',
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _emailController,
                            label: 'Email',
                            hintText: 'Nhập địa chỉ email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => InputValidators.validate(
                              value: value,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            hintText: 'Nhập số điện thoại',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => InputValidators.validate(
                              value: value,
                              hintText: 'Số điện thoại',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _locationController,
                            label: 'Địa điểm',
                            hintText: 'Nhập địa điểm',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 32),
              
                          // Thông tin công ty
                          const SectionTitle(
                            title: "THÔNG TIN CÔNG TY",
                            icon: Icons.business_rounded,
                            fontSize: 16,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyNameController,
                            label: 'Tên công ty',
                            hintText: 'Nhập tên công ty',
                            icon: Icons.business_rounded,
                            validator: (value) => InputValidators.validate(
                              value: value,
                              hintText: 'Tên công ty',
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyLocationController,
                            label: 'Địa điểm công ty',
                            hintText: 'Nhập địa điểm công ty',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyDescriptionController,
                            label: 'Mô tả công ty',
                            hintText: 'Nhập mô tả công ty',
                            icon: Icons.description_outlined,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyWebsiteController,
                            label: 'Website',
                            hintText: 'Nhập link website (nếu có)',
                            icon: Icons.public_rounded,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyScaleController,
                            label: 'Quy mô',
                            hintText: 'Nhập quy mô công ty',
                            icon: Icons.people_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => InputValidators.validate(
                              value: value,
                              hintText: 'Quy mô',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFieldWithLabel(
                            labelTextColor: Colors.black87,
                            controller: _companyIndustryController,
                            label: 'Lĩnh vực',
                            hintText: 'Nhập lĩnh vực công ty',
                            icon: Icons.construction_outlined,
                          ),
                          const SizedBox(height: 32),
              
                          // Nút lưu thay đổi
                          ButtonPrimaryGradient(
                            text: 'LƯU THAY ĐỔI',
                            onPressed: _updateCompany,
                          ),
                          const SizedBox(height: 16),
                          ButtonPrimaryGradient(
                            text: 'HỦY',
                            onPressed: () => context.pop(),
                            gradientColors: [Colors.white, Colors.white],
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
      ),
    );
  }
}
