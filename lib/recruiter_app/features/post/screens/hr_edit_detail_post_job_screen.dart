import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';

class HrEditDetailPostJobScreen extends StatefulWidget {
  final JobPostingModel jobPosting;
  final VoidCallback? onJobUpdated;

  const HrEditDetailPostJobScreen({
    super.key,
    required this.jobPosting,
    this.onJobUpdated,
  });

  @override
  State<HrEditDetailPostJobScreen> createState() => _HrEditDetailPostJobScreenState();
}

class _HrEditDetailPostJobScreenState extends State<HrEditDetailPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobPostingService = JobPostingService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _salaryController;
  late TextEditingController _locationController;
  late TextEditingController _workTypeController;
  late TextEditingController _experienceLevelController;
  late TextEditingController _descriptionController;
  late TextEditingController _requirementsController;
  late TextEditingController _benefitsController;

  late DateTime _deadline;
  late TextEditingController _deadlineController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jobPosting.title);
    _salaryController = TextEditingController(text: (widget.jobPosting.salary ?? 0).toString());
    _locationController = TextEditingController(text: widget.jobPosting.location);
    _workTypeController = TextEditingController(text: widget.jobPosting.workType);
    _experienceLevelController = TextEditingController(text: widget.jobPosting.experienceLevel);
    _descriptionController = TextEditingController(text: widget.jobPosting.description);
    _requirementsController = TextEditingController(text: widget.jobPosting.requirements);
    _benefitsController = TextEditingController(text: widget.jobPosting.benefits ?? '');
    _deadline = widget.jobPosting.applicationDeadline ?? DateTime.now();
    _deadlineController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_deadline),
    );
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
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    // Đảm bảo initialDate không nhỏ hơn firstDate
    final initialDate = _deadline.isBefore(now) ? now : _deadline;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        _deadlineController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Map WorkType từ UI format sang API enum format
  String _mapWorkTypeToApiFormat(String workType) {
    final normalized = workType.trim().toLowerCase();
    
    final mapping = {
      'full-time': 'fulltime',
      'fulltime': 'fulltime',
      'part-time': 'parttime',
      'parttime': 'parttime',
      'temporary': 'parttime',
      'freelancer': 'freelancer',
      'remote': 'remote',
      'internship': 'internship',
      'fresher': 'fresher',
      'senior': 'senior',
      'junior': 'junior',
      'contract': 'parttime',
    };
    
    if (mapping.containsKey(normalized)) {
      return mapping[normalized]!;
    }
    
    return normalized.replaceAll('-', '').replaceAll(' ', '');
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse salary
      final salary = double.tryParse(_salaryController.text.trim()) ?? 0.0;

      // Map workType
      final workTypeRaw = _workTypeController.text.trim();
      final workType = _mapWorkTypeToApiFormat(workTypeRaw);

      // Tạo JobPostingModel với dữ liệu đã chỉnh sửa
      // Khi đăng lại, set status = 'open' để đăng lên luôn không cần chờ xác nhận
      final updatedJob = widget.jobPosting.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim(),
        salary: salary,
        location: _locationController.text.trim(),
        workType: workType,
        experienceLevel: _experienceLevelController.text.trim(),
        applicationDeadline: _deadline,
        benefits: _benefitsController.text.trim(),
        postStatus: 'open', // Đăng lại luôn với status 'open'
      );

      // Update job posting (sẽ tự động set status = 'open' trong DTO)
      await _jobPostingService.updateJobPosting(
        jobId: widget.jobPosting.idJobPost,
        jobPosting: updatedJob,
      );

      if (!mounted) return;

      // Gọi callback để refresh danh sách
      widget.onJobUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật và đăng lại tin tuyển dụng thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Quay lại màn hình trước
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa tin tuyển dụng", style: TextStyle(color: Colors.white),),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: _deadlineController,
                    readOnly: true,
                    onTap: _pickDeadline,
                    decoration: InputDecoration(
                      labelText: "Hạn nộp hồ sơ",
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                      ),
                      suffixIcon: InkWell(
                        onTap: _pickDeadline,
                        child: const Icon(Icons.calendar_today),
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
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("Lưu và đăng lại",
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
