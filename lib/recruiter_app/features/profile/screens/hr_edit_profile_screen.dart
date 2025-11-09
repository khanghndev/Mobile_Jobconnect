import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/recruiter_service.dart';

class HrEditProfileScreen extends StatefulWidget {
  final UserModel account;
  final CompanyModel company;
  final RecruiterInfoModel recruiterInfo;
  const HrEditProfileScreen({super.key, 
  required this.account, required this.company, required this.recruiterInfo});

  @override
  // ignore: library_private_types_in_public_api
  _HrEditProfileScreenState createState() => _HrEditProfileScreenState();
}

class _HrEditProfileScreenState extends State<HrEditProfileScreen> {
  //Khởi tạo severice
  RecruiterService recruiterService = RecruiterService();
  UserService accountService = UserService();
  CompanyService companyService = CompanyService();

  // Khởi tạo các controller
  final _formKey = GlobalKey<FormState>();
  // Thông tin cá nhân
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  // Thông tin công ty
  final _companyNameController = TextEditingController();
  final _companyScaleController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyLogoUrlController = TextEditingController();
  final _companyIndustryController = TextEditingController();
  final _companyLocationController = TextEditingController();

  // Địa điểm
  
  // Anh đại diện
  File? _profileImage;

  // Biến trạng thái
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với dữ liệu hiện tại
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

  //Lấy ảnh từ kho ảnh 
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
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
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ảnh đại diện
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: ImageUtils.getImageProvider(
                                  widget.account.avatarUrl != null && widget.account.avatarUrl!.isNotEmpty
                                      ? widget.account.avatarUrl!
                                      : AppImages.defaultAvatar,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Thông tin cá nhân
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "THÔNG TIN CÁ NHÂN",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Họ và tên
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Họ và tên",
                          hintText: "Nhập họ và tên của bạn",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập họ và tên";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Nhập địa chỉ email của bạn",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập email";
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Số điện thoại
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          hintText: "Nhập số điện thoại của bạn",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập số điện thoại";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Địa điểm 
                      TextFormField(
                        controller: _locationController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Địa điểm",
                          hintText: "Nhập địa điểm của bạn",
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Thông tin công ty
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "THÔNG TIN CÔNG TY",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tên công ty
                      TextFormField(
                        controller: _companyNameController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Tên công ty",
                          hintText: "Nhập tên công ty",
                          prefixIcon: const Icon(Icons.business_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập tên công ty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Địa điểm công ty
                      TextFormField(
                        controller: _companyLocationController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Địa điểm công ty",
                          hintText: "Nhập địa điểm công ty của bạn",
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mô tả công ty
                      TextFormField(
                        controller: _companyDescriptionController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: "Mô tả công ty",
                          hintText: "Nhập mô tả công ty của bạn",
                          prefixIcon: const Icon(Icons.description_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Logo công ty
                      // --------------------------------------
                      // Website
                      TextFormField(
                        controller: _companyWebsiteController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Website",
                          hintText: "Nhập link website của bạn (nếu có)",
                          prefixIcon: const Icon(Icons.public_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Quy mô
                      TextFormField(
                        controller: _companyScaleController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Quy mô",
                          hintText: "Nhập quy mô công ty của bạn",
                          prefixIcon: const Icon(Icons.people_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng quy mô công ty của bạn";
                          }
                          return null;
                        },
                      ), 
                      const SizedBox(height: 20),
                      // Industry
                      TextFormField(
                        controller: _companyIndustryController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Lĩnh vực",
                          hintText: "Nhập lĩnh vực công ty của bạn",
                          prefixIcon: const Icon(Icons.construction_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Nút lưu thay đổi
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _updateCompany,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "LƯU THAY ĐỔI",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hủy
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: const Text(
                            "HỦY",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
  }
}