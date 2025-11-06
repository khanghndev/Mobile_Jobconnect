import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class HrEditDetailPostJobScreen extends StatefulWidget {
  final JobPostingModel jobPosting;

  const HrEditDetailPostJobScreen({super.key, required this.jobPosting});

  @override
  State<HrEditDetailPostJobScreen> createState() => _HrEditDetailPostJobScreenState();
}

class _HrEditDetailPostJobScreenState extends State<HrEditDetailPostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _salaryController;
  late TextEditingController _locationController;
  late TextEditingController _workTypeController;
  late TextEditingController _experienceLevelController;
  late TextEditingController _descriptionController;
  late TextEditingController _requirementsController;
  late TextEditingController _benefitsController;

  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jobPosting.title);
    _salaryController = TextEditingController(text: widget.jobPosting.salary.toString());
    _locationController = TextEditingController(text: widget.jobPosting.location);
    _workTypeController = TextEditingController(text: widget.jobPosting.workType);
    _experienceLevelController = TextEditingController(text: widget.jobPosting.experienceLevel);
    _descriptionController = TextEditingController(text: widget.jobPosting.description ?? '');
    _requirementsController = TextEditingController(text: widget.jobPosting.requirements ?? '');
    _benefitsController = TextEditingController(text: widget.jobPosting.benefits ?? '');
    _deadline = widget.jobPosting.applicationDeadline ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _workTypeController.dispose();
    _experienceLevelController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: gọi API cập nhật tin tuyển dụng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu thay đổi")),
      );
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1, IconData? icon, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: inputType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("S tin tuyển dụng", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2563EB),
        iconTheme: const IconThemeData(color: Colors.white), 
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField("Tiêu đề", _titleController, icon: Icons.title),
                _buildField("Mức lương", _salaryController,
                    icon: Icons.attach_money, inputType: TextInputType.number),
                _buildField("Địa điểm", _locationController,
                    icon: Icons.location_on),
                _buildField("Hình thức làm việc", _workTypeController,
                    icon: Icons.work_outline),
                _buildField("Kinh nghiệm", _experienceLevelController,
                    icon: Icons.timeline),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Hạn nộp hồ sơ",
                        prefixIcon: const Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      controller: TextEditingController(
                        text: dateFormat.format(_deadline),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildField("Mô tả công việc", _descriptionController,
                    icon: Icons.description, maxLines: 5),
                _buildField("Yêu cầu", _requirementsController,
                    icon: Icons.assignment, maxLines: 4),
                _buildField("Quyền lợi", _benefitsController,
                    icon: Icons.card_giftcard, maxLines: 4),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Lưu thay đổi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
