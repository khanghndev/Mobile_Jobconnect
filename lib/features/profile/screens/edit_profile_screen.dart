import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'dart:io';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/utils/pick_date.dart';
import 'package:job_connect/config/utils/pick_image.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/profile/view_model/candidate_info_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/profile/widgets/edit_profile/edit_profile_shimmer.dart';
import 'package:job_connect/features/profile/widgets/edit_profile/profile_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String idUser;
  const EditProfilePage({super.key, required this.idUser});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>with SingleTickerProviderStateMixin {
  File? _profileImage;
  bool _isLoading = true;
  bool _isSaving = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _workPositionController;
  late TextEditingController _universityNameController;
  late TextEditingController _educationLevelController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _skillsController;
  late TextEditingController _dateOfBirthController; 

  UserModel? _account;
  CandidateInfoModel? _candidateInfo;
  DateTime? _selectedDateOfBirth;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _genderDisplayMap = {
    'male': 'Nam',
    'female': 'Nữ',
    'other': 'Khác', 
  };

  late List<String> _genderApiOptions;
  String? _selectedApiGenderValue;

  @override
  void initState() {
    super.initState();
    _genderApiOptions = _genderDisplayMap.keys.toList();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _workPositionController = TextEditingController();
    _universityNameController = TextEditingController();
    _educationLevelController = TextEditingController();
    _experienceYearsController = TextEditingController();
    _skillsController = TextEditingController();
    _dateOfBirthController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadAllDataFromViewModel();
  }

  Future<void> _loadAllDataFromViewModel() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final userVM = context.read<UserViewModel>();
    final candidateVM = context.read<CandidateInfoViewModel>();

    try {
      // Chạy đồng thời cả 2 API trong ViewModel
      await Future.wait([
        userVM.getCurrentUser(widget.idUser),
        candidateVM.getCandidateDetail(widget.idUser),
      ]);

      // Lấy dữ liệu từ ViewModel
      _account = userVM.currentUser;
      _candidateInfo = candidateVM.candidateDetail;

      // Điền dữ liệu vào form
      if (_account != null) {
        _nameController.text = _account!.userName;
        _emailController.text = _account!.email;
        _phoneController.text = _account!.phoneNumber ?? '';
        _locationController.text = _account!.address ?? '';
        _selectedDateOfBirth = _account!.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').parse(_account!.dateOfBirth!.toIso8601String())
            : null;
        _dateOfBirthController.text = _selectedDateOfBirth != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
            : '';
        _selectedApiGenderValue = _account!.gender;
      }

      if (_candidateInfo != null) {
        _workPositionController.text = _candidateInfo!.workPosition ?? '';
        _universityNameController.text = _candidateInfo!.universityName ?? '';
        _educationLevelController.text = _candidateInfo!.educationLevel ?? '';
        _experienceYearsController.text =
            _candidateInfo!.experienceYears?.toString() ?? '';
        _skillsController.text = _candidateInfo!.skills ?? '';
      }

      // Bắt đầu animation
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _workPositionController.dispose();
    _universityNameController.dispose();
    _educationLevelController.dispose();
    _experienceYearsController.dispose();
    _skillsController.dispose();
    _dateOfBirthController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onPickImage(ImageSource source) async {
    final Uint8List? bytes = await pickImage(context, imageSource: source);
    if (bytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      setState(() => _profileImage = file); 
    }
  }

  Future<void> _onPickDate() async {
    final picked = await DatePickerUtils.pickDate(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = DatePickerUtils.formatDate(picked);
      });
    }
  }

  Future<void> _onSaveProfile(UserViewModel userVM, CandidateInfoViewModel candidateVM) async {
    if (!_formKey.currentState!.validate()) return;
    final user = userVM.currentUser;
    final candidate = candidateVM.candidateDetail;
    if (user == null) {
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Dữ liệu người dùng chưa được tải!',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      String? newAvatarUrl = user.avatarUrl;
      if (_profileImage != null) {
        newAvatarUrl = _profileImage?.path;
      }
      UserModel userModel = UserModel(
        idUser: user.idUser,
        userName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: user.password,
        idRole: user.idRole,
        accountStatus: user.accountStatus,
        gender: _selectedApiGenderValue ?? user.gender,
        address: _locationController.text,
        dateOfBirth: _selectedDateOfBirth,
        avatarUrl: newAvatarUrl,
        socialLogin: user.socialLogin,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
        role: user.role,
      );
      await userVM.updateUser(user.idUser, userModel);
      CandidateInfoModel candidateModel = CandidateInfoModel(
        idUser: user.idUser,
        workPosition: _workPositionController.text,
        ratingScore: candidate?.ratingScore ?? 0,
        universityName: _universityNameController.text,
        educationLevel: _educationLevelController.text,
        experienceYears:int.tryParse(_experienceYearsController.text) ?? candidate?.experienceYears ?? 0,
        skills: _skillsController.text,
      );
      if (candidate?.idUser == null) {
        await candidateVM.createCandidate(candidateModel);
      } else {
        await candidateVM.updateCandidate(user.idUser, candidateModel);
      }
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Cập nhật hồ sơ thành công',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Cập nhật thất bại: ${e.toString()}',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userVM = context.read<UserViewModel>();
    final candidateVM = context.read<CandidateInfoViewModel>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Hoàn Thiện Hồ Sơ"),
      body: _isLoading && _account == null
        ? Center(
          child: EditProfileShimmer(),
        )
        : SafeArea(
          child: UnfocusWidget(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _loadAllDataFromViewModel,
                color: theme.primaryColor,
                backgroundColor: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), 
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // TODO: AVATAR
                        ProfileImagePicker(
                          profileImage: _profileImage,
                          avatarUrl: _account?.avatarUrl,
                          onPickImage: () => _onPickImage(ImageSource.gallery),
                        ),
                        SizedBox(height: 32.h),
                        SectionTitle(
                          title: "Thông Tin Cơ Bản",
                          icon: Icons.person_pin_rounded,
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _nameController,
                          label: 'Họ và tên',
                          hintText: 'Nhập họ và tên đày đủ',
                          icon: Icons.person_outline_rounded,
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Họ và tên',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Nhập email',
                          icon: Icons.email_outlined,
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Email',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone_iphone_rounded,
                          hintText: 'Nhập số điện thoại',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Số điện thoại',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        CustomTextFieldWithLabel(
                          controller: _dateOfBirthController,
                          onTap: _onPickDate,
                          label: 'Ngày sinh',
                          icon: Icons.calendar_today,
                          hintText: 'Nhập ngày sinh',
                          suffixIcon: Icons.arrow_drop_down_circle_outlined,
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          suffixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Ngày sinh',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        DropdownButtonFormField<String>(
                          value: _selectedApiGenderValue,
                          decoration: InputDecoration(
                            labelText: 'Giới tính',
                            prefixIcon: Icon(
                              Icons.generating_tokens,
                              color: theme.primaryColor.withValues(alpha: 0.7),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor.withValues(alpha: 0.7),
                                width: 9.w,
                              ),
                            ),
                          ),
                          items: _genderApiOptions.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(_genderDisplayMap[gender] ?? gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedApiGenderValue = value;
                            });
                          },
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Giới tính',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _locationController,
                          label: 'Địa chỉ hiện tại',
                          icon: Icons.location_city_rounded,
                          hintText: 'Nhập địa chỉ hiện tại',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Địa chỉ hiện tại',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        SectionTitle(
                          title: "Thông Tin Chuyên Môn",
                          icon: Icons.work_history_rounded,
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _workPositionController,
                          label: 'Vị trí mong muốn',
                          icon: Icons.business_center_outlined,
                          hintText: 'Nhập vị trí mong muốn',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Vị trí mong muốn',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _universityNameController,
                          label: 'Trường/Cơ sở đào tạo',
                          icon: Icons.school_outlined,
                          hintText: 'Nhập trường/cơ sở đào tạo',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Trường/Cơ sở đào tạo',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _educationLevelController,
                          label: 'Trình độ học vấn',
                          icon: Icons.grade_outlined,
                          hintText: 'Nhập trình độ học vấn',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Trình độ học vấn',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _experienceYearsController,
                          label: 'Số năm kinh nghiệm',
                          icon: Icons.hourglass_top_rounded,
                          hintText: 'Nhập số năm kinh nghiệm',
                          keyboardType: TextInputType.number,
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Số năm kinh nghiệm',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFieldWithLabel(
                          controller: _skillsController,
                          label: 'Các kỹ năng chính',
                          icon: Icons.psychology_outlined,
                          hintText: 'Nhập các kỹ năng chính ',
                          prefixIconColor: theme.primaryColor.withValues(alpha:0.7),
                          fillColor: Theme.of(context).dividerColor.withValues(alpha:0.1),
                          validator: (value) => InputValidators.validate(
                            value: value,
                            hintText: 'Các kỹ năng chính',
                            keyboardType: TextInputType.number,
                          ),
                          maxLines: 3,
                        ),
            
                        SizedBox(height: 36.h),
                        CustomButtomLeadingIcon(
                            onPressed: (){
                            _isSaving ? null : _onSaveProfile(userVM, candidateVM);
                            },
                          text:  _isSaving ? "ĐANG LƯU..." : "LƯU THAY ĐỔI",
                          icon: Icons.save_alt_rounded,
                          iconColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.primaryColor,
                          textColor: theme.colorScheme.onPrimary,
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
}