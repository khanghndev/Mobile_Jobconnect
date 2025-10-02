import 'package:flutter/material.dart';

class EditCVPage extends StatefulWidget {
  // ignore: use_super_parameters
  const EditCVPage({Key? key}) : super(key: key);

  @override
  State<EditCVPage> createState() => _EditCVPageState();
}

class _EditCVPageState extends State<EditCVPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Các controller cho các trường dữ liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa CV",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: _saveCV,
            child: const Text(
              "Lưu",
              style: TextStyle(
                color: Color(0xFF66BB6A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.person,
                title: "Thông tin cá nhân",
                color: const Color(0xFF1E88E5),
              ),
              const SizedBox(height: 16),
              _buildProfileImageSection(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                label: "Họ và tên",
                hint: "Nhập họ và tên đầy đủ",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập họ và tên";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _positionController,
                label: "Vị trí công việc",
                hint: "Ví dụ: Product Manager, Developer",
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                hint: "example@email.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập email";
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "Email không hợp lệ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: "Số điện thoại",
                hint: "Nhập số điện thoại",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: "Địa chỉ",
                hint: "Nhập địa chỉ của bạn",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(
                icon: Icons.description,
                title: "Tóm tắt chuyên môn",
                color: const Color(0xFF66BB6A),
              ),
              const SizedBox(height: 16),
              _buildTextArea(
                controller: _summaryController,
                label: "Tóm tắt",
                hint:
                    "Giới thiệu ngắn gọn về bản thân và kinh nghiệm làm việc của bạn",
                maxLines: 5,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(
                icon: Icons.work,
                title: "Kinh nghiệm làm việc",
                color: const Color(0xFFFFA726),
                hasAddButton: true,
                onAddPressed: _addExperience,
              ),
              const SizedBox(height: 16),
              _buildExperienceSection(),
              const SizedBox(height: 32),

              _buildSectionHeader(
                icon: Icons.school,
                title: "Học vấn",
                color: const Color(0xFF42A5F5),
                hasAddButton: true,
                onAddPressed: _addEducation,
              ),
              const SizedBox(height: 16),
              _buildEducationSection(),
              const SizedBox(height: 32),

              _buildSectionHeader(
                icon: Icons.psychology,
                title: "Kỹ năng",
                color: const Color(0xFFAB47BC),
                hasAddButton: true,
                onAddPressed: _addSkill,
              ),
              const SizedBox(height: 16),
              _buildSkillsSection(),
              const SizedBox(height: 40),

              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    bool hasAddButton = false,
    VoidCallback? onAddPressed,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        if (hasAddButton)
          IconButton(
            icon: Icon(Icons.add_circle, color: color, size: 28),
            onPressed: onAddPressed,
          ),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Xử lý thay đổi ảnh
            },
            child: const Text(
              "Thay đổi ảnh",
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    // Mẫu hiển thị kinh nghiệm làm việc
    return Card(
      elevation: 0,
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Senior Software Developer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color(0xFFEF5350),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const Text(
              "Công ty ABC",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Color(0xFFFFA726)),
                SizedBox(width: 4),
                Text(
                  "01/2020 - Hiện tại",
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Phát triển ứng dụng di động, xây dựng các tính năng mới, tối ưu hoá hiệu suất và hướng dẫn cho các thành viên mới.",
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    // Mẫu hiển thị học vấn
    return Card(
      elevation: 0,
      color: const Color(0xFFE3F2FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Kỹ sư Công nghệ thông tin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color(0xFFEF5350),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const Text(
              "Đại học Bách Khoa",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Color(0xFF42A5F5)),
                SizedBox(width: 4),
                Text(
                  "09/2015 - 06/2019",
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Tốt nghiệp loại Giỏi. Chủ đề luận văn: Xây dựng ứng dụng hỗ trợ học tập cho sinh viên.",
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    // Mẫu hiển thị kỹ năng
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSkillChip("Flutter", const Color(0xFFAB47BC)),
        _buildSkillChip("React Native", const Color(0xFFAB47BC)),
        _buildSkillChip("UI/UX", const Color(0xFFAB47BC)),
        _buildSkillChip("Firebase", const Color(0xFFAB47BC)),
        _buildSkillChip("RESTful API", const Color(0xFFAB47BC)),
      ],
    );
  }

  Widget _buildSkillChip(String skill, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              // Xử lý xoá kỹ năng
            },
            child: Icon(Icons.close, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveCV,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF66BB6A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Lưu CV",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCV() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Giả lập quá trình lưu
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo thành công
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("CV đã được lưu thành công!"),
            backgroundColor: const Color(0xFF66BB6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Quay lại trang trước
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      });
    }
  }

  void _addExperience() {
    // Hiển thị hộp thoại thêm kinh nghiệm làm việc
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddExperienceSheet(context),
    );
  }

  Widget _buildAddExperienceSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thêm kinh nghiệm làm việc",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: TextEditingController(),
                label: "Vị trí công việc",
                hint: "Ví dụ: Software Developer",
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: TextEditingController(),
                label: "Tên công ty",
                hint: "Ví dụ: Công ty ABC",
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(),
                      label: "Thời gian bắt đầu",
                      hint: "MM/YYYY",
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(),
                      label: "Thời gian kết thúc",
                      hint: "MM/YYYY hoặc Hiện tại",
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextArea(
                controller: TextEditingController(),
                label: "Mô tả công việc",
                hint:
                    "Mô tả chi tiết công việc, trách nhiệm và thành tựu của bạn",
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý thêm kinh nghiệm
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Thêm kinh nghiệm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addEducation() {
    // Hiển thị hộp thoại thêm học vấn
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddEducationSheet(context),
    );
  }

  Widget _buildAddEducationSheet(BuildContext context) {
    // Tương tự như _buildAddExperienceSheet nhưng cho học vấn
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thêm học vấn",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: TextEditingController(),
                label: "Bằng cấp/Chuyên ngành",
                hint: "Ví dụ: Kỹ sư Công nghệ thông tin",
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: TextEditingController(),
                label: "Tên trường",
                hint: "Ví dụ: Đại học Bách Khoa",
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(),
                      label: "Thời gian bắt đầu",
                      hint: "MM/YYYY",
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: TextEditingController(),
                      label: "Thời gian kết thúc",
                      hint: "MM/YYYY",
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextArea(
                controller: TextEditingController(),
                label: "Mô tả",
                hint:
                    "Mô tả thành tích học tập, các giải thưởng, hoạt động ngoại khóa",
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý thêm học vấn
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Thêm học vấn",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addSkill() {
    // Hiển thị hộp thoại thêm kỹ năng
    showDialog(
      context: context,
      builder: (context) => _buildAddSkillDialog(context),
    );
  }

  Widget _buildAddSkillDialog(BuildContext context) {
    final TextEditingController skillController = TextEditingController();

    return AlertDialog(
      title: const Text(
        "Thêm kỹ năng",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      content: _buildTextField(
        controller: skillController,
        label: "Tên kỹ năng",
        hint: "Ví dụ: Flutter, React, JavaScript",
        icon: Icons.psychology_outlined,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Hủy",
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Xử lý thêm kỹ năng
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAB47BC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Thêm",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Hàm để tạo nút tùy chọn trong bottom sheet
// ignore: unused_element
Widget _buildOptionButton({
  required IconData icon,
  required String label,
  required String description,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF9E9E9E),
            size: 16,
          ),
        ],
      ),
    ),
  );
}
