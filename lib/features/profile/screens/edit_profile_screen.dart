import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/core/data/models/account_model.dart';
import 'package:job_connect/core/data/models/candidate_info_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:intl/intl.dart'; // For DatePicker

class EditProfilePage extends StatefulWidget {
  final String idUser;
  const EditProfilePage({Key? key, required this.idUser}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  bool _isLoading = true;
  bool _isSaving = false; // Trạng thái khi đang lưu
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
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
  late TextEditingController _dateOfBirthController; // For DatePicker

  Account? _account;
  CandidateInfo? _candidateInfo;
  DateTime? _selectedDateOfBirth;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _genderDisplayMap = {
    'male': 'Nam',
    'female': 'Nữ',
    // 'other': 'Khác', // Bỏ đi nếu DB chỉ có male/female
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

    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _fetchAccount(),
        _fetchCandidateInfo(),
      ]);
      _account = results[0] as Account?;
      _candidateInfo = results[1] as CandidateInfo?;

      print(_candidateInfo);

      if (_account != null) {
        _nameController.text = _account!.userName;
        _emailController.text = _account!.email;
        _phoneController.text = _account!.phoneNumber ?? "";
        _locationController.text = _account!.address ?? "";
        _selectedDateOfBirth = _account!.dateOfBirth;
        _dateOfBirthController.text =
            _selectedDateOfBirth != null
                ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
                : "";
        _selectedApiGenderValue = _account!.gender;
      }

      if (_candidateInfo != null) {
        _workPositionController.text = _candidateInfo?.workPosition ?? "";
        _universityNameController.text = _candidateInfo?.universityName ?? "";
        _educationLevelController.text = _candidateInfo?.educationLevel ?? "";
        _experienceYearsController.text =
            _candidateInfo?.experienceYears?.toString() ?? "";
        _skillsController.text = _candidateInfo?.skills ?? "";
      }
      _animationController.forward(); // Start animation after data is loaded
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

  Future<Account?> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) return Account.fromJson(data.first);
    } catch (e) {
      print("Lỗi fetch Account: $e");
      rethrow;
    }
    return null;
  }

  Future<CandidateInfo?> _fetchCandidateInfo() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.candidateInfoEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) return CandidateInfo.fromJson(data.first);
      return CandidateInfo(
        idUser: null,
      ); // Trả về CandidateInfo rỗng nếu không có
    } catch (e) {
      print("Lỗi fetch CandidateInfo: $e");
      rethrow;
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      if (image != null) setState(() => _profileImage = File(image.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể chọn ảnh')));
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // Mặc định 18 tuổi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Custom theme cho DatePicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(context).primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).primaryColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu người dùng chưa được tải!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? newAvatarUrl = _account!.avatarUrl;
      if (_profileImage != null) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate upload
        newAvatarUrl =
            "https://via.placeholder.com/300/007BFF/FFFFFF?Text=NewAvatar";
      }

      Map<String, dynamic> userData = {
        "userName": _nameController.text,
        "email": _emailController.text,
        "phoneNumber": _phoneController.text,
        "password": _account!.password,
        "accountStatus": _account!.accountStatus,
        "gender": _selectedApiGenderValue, // Gửi 'male', 'female', hoặc null
        "address": _locationController.text,
        "dateOfBirth": _selectedDateOfBirth?.toIso8601String(),
        "avatarUrl": newAvatarUrl,
        "socialLogin": _account!.socialLogin,
        "updatedAt": DateTime.now().toIso8601String(),
      };

      await _apiService.put(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
        userData,
      );

      Map<String, dynamic> candidateData = {
        "workPosition": _workPositionController.text,
        "ratingScore": _candidateInfo?.ratingScore ?? 0,
        "universityName": _universityNameController.text,
        "educationLevel": _educationLevelController.text,
        "experienceYears":
            int.tryParse(_experienceYearsController.text) ??
            _candidateInfo?.experienceYears ??
            0,
        "skills": _skillsController.text,
      };

      if (_candidateInfo!.idUser == null) {
        candidateData.addAll({
          "idUser": widget.idUser, // Thêm idUser nếu là tạo mới
        });
        await _apiService.post(
          ApiConstants.candidateInfoEndpoint,
          candidateData,
        );
      } else {
        await _apiService.put(
          '${ApiConstants.candidateInfoEndpoint}/${widget.idUser}',
          candidateData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Lớn hơn
              fontWeight: FontWeight.bold, // Đậm hơn
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String labelText,
    String hintText,
    IconData? prefixIcon, {
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon:
          prefixIcon != null
              ? Icon(
                prefixIcon,
                color: theme.primaryColor.withOpacity(0.7),
                size: 20,
              )
              : null,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
        0.3,
      ), // Màu nền nhẹ nhàng hơn
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Bo góc lớn hơn
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ), // Viền mỏng khi enable
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 2,
        ), // Viền đậm khi focus
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Tăng padding
    );
  }

  Widget _buildProfileImagePicker(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  // Vòng tròn ngoài tạo hiệu ứng
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.3),
                        theme.colorScheme.secondary.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : _account?.avatarUrl != null &&
                              _account!.avatarUrl!.isNotEmpty
                          ? NetworkImage(_account!.avatarUrl!)
                          : null,
                  child:
                      (_profileImage == null &&
                              (_account?.avatarUrl == null ||
                                  _account!.avatarUrl!.isEmpty))
                          ? Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 60,
                            color: theme.primaryColor.withOpacity(0.6),
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              Icons.photo_library_outlined,
              color: theme.primaryColor,
              size: 20,
            ),
            label: Text(
              "Thay đổi ảnh đại diện",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: _inputDecoration(label, hint, icon).copyWith(
          fillColor:
              readOnly
                  ? Theme.of(context).dividerColor.withOpacity(0.1)
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
          counterText: "", // Ẩn counter text của maxLength
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: _dateOfBirthController,
        readOnly: true,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(
          "Ngày sinh",
          "Chọn ngày sinh",
          Icons.calendar_today_rounded,
          suffixIcon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
        ),
        onTap: _selectDate,
        validator: (value) {
          if (value == null || value.isEmpty) return "Vui lòng chọn ngày sinh";
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: DropdownButtonFormField<String>(
        value:
            _selectedApiGenderValue, // Giá trị hiện tại là 'male' hoặc 'female' hoặc null
        items:
            _genderApiOptions.map((String apiValue) {
              // Lặp qua ['male', 'female']
              return DropdownMenuItem<String>(
                value: apiValue, // value của item là 'male' hoặc 'female'
                child: Text(
                  _genderDisplayMap[apiValue] ??
                      apiValue, // Hiển thị 'Nam' hoặc 'Nữ'
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          // newValue sẽ là 'male' hoặc 'female'
          setState(() {
            _selectedApiGenderValue = newValue;
          });
        },
        decoration: _inputDecoration(
          "Giới tính",
          "Chọn giới tính",
          Icons.wc_rounded,
        ),
        validator: (value) => value == null ? 'Vui lòng chọn giới tính' : null,
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.arrow_drop_down_circle_outlined,
          color: theme.primaryColor.withOpacity(0.7),
        ),
        hint: Text(
          // Hint sẽ hiển thị nếu _selectedApiGenderValue là null
          "Chọn giới tính",
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Nền chung
      appBar: AppBar(
        elevation: 1,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed:
              () => Navigator.pop(
                context,
                false,
              ), // false vì không có thay đổi nếu chỉ back
        ),
        title: Text(
          "Hoàn Thiện Hồ Sơ",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              theme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      ),
      body:
          _isLoading && _account == null
              ? Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadAllData,
                  color: theme.primaryColor,
                  backgroundColor: theme.colorScheme.surface,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn nảy
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileImagePicker(theme),
                          const SizedBox(height: 15),

                          _buildSectionTitle(
                            "Thông Tin Cơ Bản",
                            Icons.person_pin_rounded,
                          ),
                          _buildTextField(
                            _nameController,
                            "Họ và tên",
                            "Nhập họ và tên đầy đủ",
                            Icons.person_outline_rounded,
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? "Họ tên không được để trống"
                                        : null,
                          ),
                          _buildTextField(
                            _emailController,
                            "Email",
                            "Địa chỉ email của bạn",
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true, // Email không cho sửa
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Email không được để trống";
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(v))
                                return "Email không hợp lệ";
                              return null;
                            },
                          ),
                          _buildTextField(
                            _phoneController,
                            "Số điện thoại",
                            "Nhập số điện thoại liên lạc",
                            Icons.phone_iphone_rounded,
                            keyboardType: TextInputType.phone,
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? "Số điện thoại không được để trống"
                                        : null,
                          ),
                          _buildDatePickerField(),
                          _buildGenderDropdown(),
                          _buildTextField(
                            _locationController,
                            "Địa chỉ hiện tại",
                            "VD: Quận 1, TP. Hồ Chí Minh",
                            Icons.location_city_rounded,
                          ),

                          _buildSectionTitle(
                            "Thông Tin Chuyên Môn",
                            Icons.work_history_rounded,
                          ),
                          _buildTextField(
                            _workPositionController,
                            "Vị trí mong muốn",
                            "VD: Lập trình viên Frontend",
                            Icons.business_center_outlined,
                          ),
                          _buildTextField(
                            _universityNameController,
                            "Trường/Cơ sở đào tạo",
                            "VD: Đại học Công Nghệ Thông Tin",
                            Icons.school_outlined,
                          ),
                          _buildTextField(
                            _educationLevelController,
                            "Trình độ học vấn",
                            "VD: Cử nhân, Thạc sĩ",
                            Icons.grade_outlined,
                          ),
                          _buildTextField(
                            _experienceYearsController,
                            "Số năm kinh nghiệm",
                            "VD: 3",
                            Icons.hourglass_top_rounded,
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    (v != null &&
                                            v.isNotEmpty &&
                                            int.tryParse(v) == null)
                                        ? "Vui lòng nhập số"
                                        : null,
                          ),
                          _buildTextField(
                            _skillsController,
                            "Các kỹ năng chính",
                            "VD: Flutter, Dart, UI/UX Design (cách nhau bởi dấu phẩy)",
                            Icons.psychology_outlined,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 35),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            icon:
                                _isSaving
                                    ? Container(
                                      width: 22,
                                      height: 22,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.save_alt_rounded,
                                      size: 22,
                                    ),
                            label: Text(
                              _isSaving ? "ĐANG LƯU..." : "LƯU THAY ĐỔI",
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.textTheme.bodyLarge?.color
                                  ?.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "HỦY BỎ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
