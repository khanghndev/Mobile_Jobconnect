import 'package:flutter/material.dart';

class CreateCVPage extends StatefulWidget {
  // ignore: use_super_parameters
  const CreateCVPage({Key? key}) : super(key: key);

  @override
  State<CreateCVPage> createState() => _CreateCVPageState();
}

class _CreateCVPageState extends State<CreateCVPage> {
  final List<CVTemplate> templates = [
    CVTemplate(
      id: 1,
      name: "Chuyên nghiệp",
      image: "assets/templates/professional.png",
      color: const Color(0xFF1E88E5),
    ),
    CVTemplate(
      id: 2,
      name: "Hiện đại",
      image: "assets/templates/modern.png",
      color: const Color(0xFF66BB6A),
    ),
    CVTemplate(
      id: 3,
      name: "Sáng tạo",
      image: "assets/templates/creative.png",
      color: const Color(0xFFFFA726),
    ),
    CVTemplate(
      id: 4,
      name: "Đơn giản",
      image: "assets/templates/simple.png",
      color: const Color(0xFF78909C),
    ),
  ];

  int selectedTemplateId = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Tạo CV mới",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 24),

              // Template selection section
              _buildSectionTitle("Chọn mẫu CV"),
              const SizedBox(height: 16),
              _buildTemplateGrid(),
              const SizedBox(height: 32),

              // Personal information section
              _buildSectionTitle("Thông tin cá nhân"),
              const SizedBox(height: 16),
              _buildPersonalInfoForm(),
              const SizedBox(height: 32),

              // Education section
              _buildSectionTitle("Học vấn"),
              const SizedBox(height: 16),
              _buildEducationSection(),
              const SizedBox(height: 32),

              // Experience section
              _buildSectionTitle("Kinh nghiệm làm việc"),
              const SizedBox(height: 16),
              _buildExperienceSection(),
              const SizedBox(height: 32),

              // Skills section
              _buildSectionTitle("Kỹ năng"),
              const SizedBox(height: 16),
              _buildSkillsSection(),
              const SizedBox(height: 32),

              // Preview and save buttons
              _buildActionButtons(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = template.id == selectedTemplateId;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTemplateId = template.id;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? template.color : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: template.color.withValues(alpha:0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.description,
                        size: 80,
                        color: template.color,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: template.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField("Họ", Icons.person_outline)),
              const SizedBox(width: 16),
              Expanded(child: _buildInputField("Tên", Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField("Vị trí công việc", Icons.work_outline),
          const SizedBox(height: 16),
          _buildInputField("Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _buildInputField("Số điện thoại", Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildInputField("Địa chỉ", Icons.location_on_outlined),
          const SizedBox(height: 16),
          _buildTextArea("Giới thiệu bản thân", Icons.edit_note),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF42A5F5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildTextArea(String label, IconData icon) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 64),
          child: Icon(icon, color: const Color(0xFF42A5F5)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionItem("Học vấn #1", [
            _buildInputField("Tên trường", Icons.school_outlined),
            const SizedBox(height: 16),
            _buildInputField("Chuyên ngành", Icons.book_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    "Bắt đầu",
                    Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    "Kết thúc",
                    Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextArea("Mô tả", Icons.edit_note),
          ]),
          const SizedBox(height: 16),
          _buildAddButton("Thêm học vấn"),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionItem("Kinh nghiệm #1", [
            _buildInputField("Tên công ty", Icons.business_outlined),
            const SizedBox(height: 16),
            _buildInputField("Vị trí", Icons.work_outline),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    "Bắt đầu",
                    Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    "Kết thúc",
                    Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextArea("Mô tả công việc", Icons.edit_note),
          ]),
          const SizedBox(height: 16),
          _buildAddButton("Thêm kinh nghiệm"),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField("Kỹ năng", Icons.psychology_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildInputField("Mức độ", Icons.star_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField("Kỹ năng", Icons.psychology_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildInputField("Mức độ", Icons.star_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField("Kỹ năng", Icons.psychology_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildInputField("Mức độ", Icons.star_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAddButton("Thêm kỹ năng"),
        ],
      ),
    );
  }

  Widget _buildSectionItem(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.expand_more, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildAddButton(String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, color: Color(0xFF1E88E5)),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1E88E5),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            // ignore: sort_child_properties_last
            child: const Text(
              "Xem trước",
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF1E88E5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            // ignore: sort_child_properties_last
            child: const Text(
              "Lưu CV",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1E88E5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Model cho mẫu CV
class CVTemplate {
  final int id;
  final String name;
  final String image;
  final Color color;

  CVTemplate({
    required this.id,
    required this.name,
    required this.image,
    required this.color,
  });
}

// Widget cho nút tùy chọn (có sẵn từ mã của bạn)
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
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: color.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withValues(alpha:0.2),
              shape: BoxShape.circle,
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF333333),
            size: 16,
          ),
        ],
      ),
    ),
  );
}
