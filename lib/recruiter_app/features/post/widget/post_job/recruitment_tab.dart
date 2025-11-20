import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';

class RecruitmentTab extends StatefulWidget {
  final bool isPremiumUser;

  const RecruitmentTab({super.key, this.isPremiumUser = false});

  @override
  State<RecruitmentTab> createState() => _RecruitmentTabWidgetState();
}

class _RecruitmentTabWidgetState extends State<RecruitmentTab> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Dropdown values
  String _jobType = 'Toàn thời gian';
  String _experienceLevel = 'Chưa có kinh nghiệm';
  String _location = 'Hà Nội';
  DateTime? _selectedDeadline;

  // Checkbox
  bool _isUrgent = false;

  // Options
  final List<String> _jobTypes = ['Toàn thời gian', 'Bán thời gian', 'Thực tập', 'Freelancer'];
  final List<String> _experienceLevels = ['Chưa có kinh nghiệm', '1-3 năm', '3-5 năm', '5+ năm'];
  final List<String> _locations = ['Hà Nội', 'TP. HCM', 'Đà Nẵng', 'Khác'];

  void _pickDeadline() async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? now),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _requirementsController.clear();
    _benefitsController.clear();
    _salaryController.clear();
    _locationController.clear();
    setState(() {
      _jobType = _jobTypes.first;
      _experienceLevel = _experienceLevels.first;
      _location = _locations.first;
      _selectedDeadline = null;
      _isUrgent = false;
    });
  }

  void _createJobPosting() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng tin tuyển dụng thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tạo tin tuyển dụng mới",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Section Basic
              SectionTitle(
                title: "THÔNG TIN CƠ BẢN",
                icon: Icons.person_pin_rounded,
                fontSize: 16.sp,
              ),
              SizedBox(height: 16.h),

              CustomTextFieldWithLabel(
                controller: _titleController,
                label: 'Tiêu đề công việc',
                hintText: 'Ví dụ: Kỹ sư phần mềm Flutter',
                icon: Icons.work_outline,
                labelTextColor: theme.hintColor.withOpacity(0.5),
                prefixIconColor: theme.hintColor.withOpacity(0.7),
                fillColor: theme.dividerColor.withOpacity(0.1),
                validator: (value) => InputValidators.validate(value: value, hintText: 'Tiêu đề công việc'),
              ),
              SizedBox(height: 16.h),

              CustomTextFieldWithLabel(
                controller: _descriptionController,
                label: 'Mô tả công việc',
                hintText: 'Mô tả chi tiết về công việc, trách nhiệm và kỳ vọng',
                icon: Icons.description_outlined,
                maxLines: 5,
                labelTextColor: theme.hintColor.withOpacity(0.5),
                prefixIconColor: theme.hintColor.withOpacity(0.7),
                fillColor: theme.dividerColor.withOpacity(0.1),
                validator: (value) => InputValidators.validate(value: value, hintText: 'Mô tả công việc'),
              ),
              SizedBox(height: 16.h),

              CustomTextFieldWithLabel(
                controller: _requirementsController,
                label: 'Yêu cầu ứng viên',
                hintText: 'Kỹ năng, bằng cấp, kinh nghiệm cần thiết',
                icon: Icons.assignment_outlined,
                maxLines: 4,
                labelTextColor: theme.hintColor.withOpacity(0.5),
                prefixIconColor: theme.hintColor.withOpacity(0.7),
                fillColor: theme.dividerColor.withOpacity(0.1),
              ),
              SizedBox(height: 16.h),

              CustomTextFieldWithLabel(
                controller: _benefitsController,
                label: 'Quyền lợi',
                hintText: 'Chế độ bảo hiểm, thưởng, phúc lợi khác',
                icon: Icons.card_giftcard_outlined,
                maxLines: 4,
                labelTextColor: theme.hintColor.withOpacity(0.5),
                prefixIconColor: theme.hintColor.withOpacity(0.7),
                fillColor: theme.dividerColor.withOpacity(0.1),
              ),
              SizedBox(height: 16.h),

              // Deadline
              InkWell(
                onTap: _pickDeadline,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn nộp',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                  ),
                  child: Text(
                    _selectedDeadline != null
                        ? DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDeadline!)
                        : 'Chọn hạn nộp',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDeadline != null ? Colors.black : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Section Detail
              SectionTitle(
                title: "THÔNG TIN CHI TIẾT",
                icon: Icons.info_outline_rounded,
                fontSize: 16.sp,
              ),
              SizedBox(height: 16.h),

              // Job type dropdown
              _buildDropdownField(
                label: 'Loại hình làm việc',
                icon: Icons.access_time,
                iconColor: theme.primaryColor,
                value: _jobType,
                items: _jobTypes,
                onChanged: (val) => setState(() => _jobType = val),
              ),
              SizedBox(height: 16.h),

              // Salary
              _buildTextFieldWithIcon(
                controller: _salaryController,
                label: 'Mức lương',
                hint: 'VNĐ/tháng',
                icon: Icons.monetization_on_outlined,
                iconColor: theme.primaryColor,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mức lương';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Experience dropdown
              _buildDropdownField(
                label: 'Kinh nghiệm',
                icon: Icons.trending_up_outlined,
                iconColor: theme.primaryColor,
                value: _experienceLevel,
                items: _experienceLevels,
                onChanged: (val) => setState(() => _experienceLevel = val),
              ),
              SizedBox(height: 16.h),

              // Location dropdown
              _buildDropdownField(
                label: 'Địa điểm làm việc',
                icon: Icons.location_on_outlined,
                iconColor: theme.primaryColor,
                value: _location,
                items: _locations,
                onChanged: (val) {
                  setState(() {
                    _location = val;
                    _locationController.text = val;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Urgent checkbox
              CheckboxListTile(
                enabled: widget.isPremiumUser,
                title: Text(
                  "Đánh dấu tin tuyển gấp",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                subtitle: !widget.isPremiumUser
                    ? Text(
                        "Cần đăng kí gói Premium",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          fontSize: 12.sp,
                        ),
                      )
                    : null,
                value: _isUrgent,
                onChanged: widget.isPremiumUser ? (val) => setState(() => _isUrgent = val!) : null,
                activeColor: theme.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),

              SizedBox(height: 32.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: theme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Hủy",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _createJobPosting,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_outlined, color: Colors.white, size: 20.w),
                          SizedBox(width: 8.w),
                          Text(
                            "Đăng tin tuyển dụng",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: dropdown field
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Colors.black54)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, size: 24.w),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: Colors.black87),
                    items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onChanged(newValue); // gọi callback của bạn
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: textfield with icon
  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Colors.black54)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: iconColor, size: 20.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          ),
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
      ],
    );
  }
}