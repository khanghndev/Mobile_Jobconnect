import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_detail_calendar_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/interview/view_model/interview_schedule_view_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class HrEditCalendarInterviewSchedule extends StatefulWidget {
  final InterviewScheduleModel interview;
  final List<JobPostingModel> jobs;
  final List<UserModel> candidates;

  const HrEditCalendarInterviewSchedule({
    super.key,
    required this.interview,
    required this.jobs,
    required this.candidates,
  });

  @override
  State<HrEditCalendarInterviewSchedule> createState() =>
      _HrEditCalendarInterviewScheduleState();
}

class _HrEditCalendarInterviewScheduleState
    extends State<HrEditCalendarInterviewSchedule> {
  late JobPostingModel? selectedJob;
  late UserModel? selectedCandidate;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController interviewerController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();

    selectedJob = widget.jobs.firstWhere(
      (job) => job.idJobPost == widget.interview.idJobPost,
      orElse: () => widget.jobs.first,
    );

    selectedCandidate = widget.candidates.firstWhere(
      (user) => user.idUser == widget.interview.idUser,
      orElse: () => widget.candidates.first,
    );

    timeController = TextEditingController(
        text:
            "${widget.interview.interviewDate.hour.toString().padLeft(2, '0')}:${widget.interview.interviewDate.minute.toString().padLeft(2, '0')} "
            "${widget.interview.interviewDate.day}/${widget.interview.interviewDate.month}/${widget.interview.interviewDate.year}");
    locationController = TextEditingController(text: widget.interview.location ?? "");
    interviewerController = TextEditingController(text: widget.interview.interviewer ?? "");
    noteController = TextEditingController(text: widget.interview.note ?? "");
  }

  @override
  void dispose() {
    timeController.dispose();
    locationController.dispose();
    interviewerController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _saveInterview(InterviewScheduleViewModel vm) {
    // Convert time text sang DateTime (giả sử format HH:mm dd/MM/yyyy)
    final parts = timeController.text.split(' ');
    if (parts.length != 2) return;

    final hm = parts[0].split(':');
    final dmy = parts[1].split('/');

    if (hm.length != 2 || dmy.length != 3) return;

    final dateTime = DateTime(
      int.parse(dmy[2]),
      int.parse(dmy[1]),
      int.parse(dmy[0]),
      int.parse(hm[0]),
      int.parse(hm[1]),
    );

    final updatedInterview = widget.interview.copyWith(
      idJobPost: selectedJob?.idJobPost,
      idUser: selectedCandidate?.idUser,
      interviewDate: dateTime,
      location: locationController.text,
      interviewer: interviewerController.text,
      note: noteController.text,
    );

    vm.updateSchedule(updatedInterview).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật lịch phỏng vấn thành công')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HrDetailCalendarInterviewSchedule(
            interview: updatedInterview,
            jobs: widget.jobs,
            candidates: widget.candidates,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<InterviewScheduleViewModel>(
      builder: (context, vm, child) {
        return OverlayLoading(
          isLoading: vm.isLoading,
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: const CustomAppbarTitleLarge(title: 'Chỉnh sửa lịch phỏng vấn'),
            body: UnfocusWidget(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: "THÔNG TIN LỊCH PHỎNG VẤN",
                        icon: Icons.person_pin_outlined,
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 16.h),
          
                      // Dropdown chọn job
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<JobPostingModel>(
                          isExpanded: true,
                          value: selectedJob,
                          items: widget.jobs
                              .map(
                                (job) => DropdownMenuItem<JobPostingModel>(
                                  value: job,
                                  child: Text(
                                    job.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black.withOpacity(0.87),
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => selectedJob = value),
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề công việc',
                            prefixIcon: Icon(Icons.work_outline, size: 24.sp),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down, size: 24.sp),
                        ),
                      ),
                      SizedBox(height: 12.h),
          
                      // Dropdown chọn candidate
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<UserModel>(
                          isExpanded: true,
                          value: selectedCandidate,
                          items: widget.candidates
                              .map(
                                (user) => DropdownMenuItem<UserModel>(
                                  value: user,
                                  child: Text(
                                    user.userName,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black.withOpacity(0.87),
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => selectedCandidate = value),
                          decoration: InputDecoration(
                            labelText: 'Ứng viên',
                            prefixIcon: Icon(Icons.person_outline, size: 24.sp),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down, size: 24.sp),
                        ),
                      ),
                      SizedBox(height: 12.h),
          
                      // Thời gian
                      CustomTextFieldWithLabel(
                        labelTextColor: Colors.black87,
                        controller: timeController,
                        label: 'Thời gian',
                        hintText: 'Thời gian',
                        icon: Icons.access_time,
                        readOnly: false,
                      ),
                      SizedBox(height: 12.h),
          
                      // Địa điểm
                      CustomTextFieldWithLabel(
                        labelTextColor: Colors.black87,
                        controller: locationController,
                        label: 'Địa điểm',
                        hintText: 'Địa điểm',
                        icon: Icons.location_on_outlined,
                        readOnly: false,
                      ),
                      SizedBox(height: 12.h),
          
                      // Người phỏng vấn
                      CustomTextFieldWithLabel(
                        labelTextColor: Colors.black87,
                        controller: interviewerController,
                        label: 'Người phỏng vấn',
                        hintText: 'Người phỏng vấn',
                        icon: Icons.person_search_outlined,
                        readOnly: false,
                      ),
                      SizedBox(height: 16.h),
          
                      SectionTitle(
                        title: "GHI CHÚ",
                        icon: Icons.sticky_note_2_outlined,
                        fontSize: 16.sp,
                      ),
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
                          onPressed: vm.isLoading
                              ? null
                              : () => _saveInterview(vm),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: vm.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Lưu thông tin",
                                  style: TextStyle(
                                      fontSize: 16.sp, fontWeight: FontWeight.bold),
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
      },
    );
  }
}
