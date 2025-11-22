import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/recruiter_app/features/interview/view_model/interview_schedule_view_model.dart';

class HrCreateCalendarInterviewSchedule extends StatefulWidget {
  final List<JobPostingModel> jobs;
  final List<UserModel> candidateList;

  const HrCreateCalendarInterviewSchedule({
    super.key,
    required this.jobs,
    required this.candidateList,
  });

  @override
  State<HrCreateCalendarInterviewSchedule> createState() =>
      _HrCreateCalendarInterviewScheduleState();
}

class _HrCreateCalendarInterviewScheduleState
    extends State<HrCreateCalendarInterviewSchedule> {
  final _formKey = GlobalKey<FormState>();
  late InterviewScheduleViewModel vm;

  // Controllers
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController interviewModeController = TextEditingController();
  final TextEditingController interviewerController = TextEditingController();

  String? selectedJobId;
  String? selectedCandidateId;
  String? selectedInterviewMode;
  DateTime selectedDateTime = DateTime.now();

  final List<String> interviewModeOptions = ["Trực tiếp", "Online"];

  @override
  void initState() {
    super.initState();
    interviewerController.text = "HR"; // mặc định
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm = context.read<InterviewScheduleViewModel>();
    });
  }

  @override
  void dispose() {
    timeController.dispose();
    locationController.dispose();
    noteController.dispose();
    interviewModeController.dispose();
    interviewerController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) =>
      "${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')} "
      "${dateTime.day}/${dateTime.month}/${dateTime.year}";

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      timeController.text = _formatDateTime(selectedDateTime);
    });
  }

  Future<void> _createInterview() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedJobId == null || selectedCandidateId == null || selectedInterviewMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin"), backgroundColor: Colors.red),
      );
      return;
    }

    final model = InterviewScheduleModel(
      idSchedule: "",
      idJobPost: selectedJobId!,
      idUser: selectedCandidateId!,
      interviewDate: selectedDateTime,
      interviewMode: selectedInterviewMode,
      location: locationController.text.trim(),
      interviewer: interviewerController.text.trim(),
      note: noteController.text.trim(),
    );

    await vm.createSchedule(model);

    if (vm.isSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo lịch phỏng vấn thành công!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (vm.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = context.watch<InterviewScheduleViewModel>();
    final theme = Theme.of(context);

    return OverlayLoading(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: const CustomAppbarTitleLarge(title: 'Tạo lịch phỏng vấn'),
        body: UnfocusWidget(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: "THÔNG TIN LỊCH PHỎNG VẤN", icon: Icons.calendar_today_outlined, fontSize: 16.sp),
                    SizedBox(height: 16.h),

                    // Job dropdown
                    DropdownButtonFormField<String>(
                      value: selectedJobId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Công việc",
                        prefixIcon: Icon(Icons.work_outline, size: 24.sp),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      items: widget.jobs.map((job) {
                        return DropdownMenuItem(
                          value: job.idJobPost,
                          child: Text(job.title, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedJobId = value),
                      validator: (value) => value == null ? "Vui lòng chọn công việc" : null,
                    ),
                    SizedBox(height: 12.h),

                    // Candidate dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCandidateId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Ứng viên",
                        prefixIcon: Icon(Icons.person_outline, size: 24.sp),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      items: widget.candidateList.map((user) {
                        return DropdownMenuItem(
                          value: user.idUser,
                          child: Text(user.userName, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCandidateId = value),
                      validator: (value) => value == null ? "Vui lòng chọn ứng viên" : null,
                    ),
                    SizedBox(height: 12.h),

                    // Time
                    CustomTextFieldWithLabel(
                      labelTextColor: Colors.black87,
                      controller: timeController,
                      label: 'Thời gian',
                      hintText: 'HH:MM DD/MM/YYYY',
                      icon: Icons.access_time,
                      readOnly: true,
                      onTap: _pickDateTime,
                      validator: (value) => (value == null || value.isEmpty) ? "Chọn thời gian" : null,
                    ),
                    SizedBox(height: 12.h),

                    // Interview mode
                    DropdownButtonFormField<String>(
                      value: selectedInterviewMode,
                      decoration: InputDecoration(
                        labelText: "Hình thức phỏng vấn",
                        prefixIcon: Icon(Icons.video_call_outlined, size: 24.sp),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      items: interviewModeOptions.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedInterviewMode = value),
                      validator: (value) => value == null ? "Vui lòng chọn hình thức" : null,
                    ),
                    SizedBox(height: 12.h),

                    // Location
                    CustomTextFieldWithLabel(
                      labelTextColor: Colors.black87,
                      controller: locationController,
                      label: 'Địa điểm',
                      hintText: 'Nhập địa điểm',
                      icon: Icons.location_on_outlined,
                      validator: (value) => InputValidators.validate(value: value, hintText: 'Địa điểm'),
                    ),
                    SizedBox(height: 12.h),

                    // Interviewer
                    CustomTextFieldWithLabel(
                      labelTextColor: Colors.black87,
                      controller: interviewerController,
                      label: 'Người phỏng vấn',
                      hintText: 'Tên người phỏng vấn',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16.h),

                    SectionTitle(title: "GHI CHÚ", icon: Icons.sticky_note_2_outlined, fontSize: 16.sp),
                    SizedBox(height: 8.h),

                    CustomInputField(
                      controller: noteController,
                      maxLines: 4,
                      fillColor: Colors.white,
                      borderColor: Colors.grey.shade300,
                      hintText: "Nhập ghi chú",
                    ),
                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : _createInterview,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text("Tạo lịch phỏng vấn", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
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
