import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_edit_calendar_interview_schedule.dart';

class HrDetailCalendarInterviewSchedule extends StatelessWidget {
  final InterviewScheduleModel interview;
  final List<JobPostingModel> jobs;
  final List<UserModel> candidates;

  const HrDetailCalendarInterviewSchedule({
    super.key,
    required this.interview,
    required this.jobs,
    required this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    final JobPostingModel selectedJob = jobs.firstWhere(
      (job) => job.idJobPost == interview.idJobPost,
      orElse: () => jobs.first,
    );

    final UserModel selectedCandidate = candidates.firstWhere(
      (user) => user.idUser == interview.idUser,
      orElse: () => candidates.first,
    );

    final TextEditingController jobController =
        TextEditingController(text: selectedJob.title);
    final TextEditingController candidateController =
        TextEditingController(text: selectedCandidate.userName);
    final TextEditingController timeController = TextEditingController(
        text:
            "${interview.interviewDate.hour.toString().padLeft(2, '0')}:${interview.interviewDate.minute.toString().padLeft(2, '0')} "
            "${interview.interviewDate.day}/${interview.interviewDate.month}/${interview.interviewDate.year}");
    final TextEditingController locationController =
        TextEditingController(text: interview.location ?? "Chưa có địa điểm");
    final TextEditingController interviewerController =
        TextEditingController(text: interview.interviewer ?? "Chưa có người phỏng vấn");
    final TextEditingController noteController =
        TextEditingController(text: interview.note ?? "Không có ghi chú");

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppbarTitleLarge(
        title: 'Chi tiết lịch phỏng vấn',
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HrEditCalendarInterviewSchedule(
                    interview: interview,
                    jobs: jobs,
                    candidates: candidates,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.edit,
              color: Colors.black87,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: UnfocusWidget(
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

              CustomTextFieldWithLabel(
                labelTextColor: Colors.black87,
                controller: jobController,
                label: 'Tiêu đề công việc',
                hintText: 'Tiêu đề công việc',
                icon: Icons.work_outline,
                readOnly: true,
              ),
              SizedBox(height: 12.h),

              CustomTextFieldWithLabel(
                labelTextColor: Colors.black87,
                controller: candidateController,
                label: 'Tên ứng viên',
                hintText: 'Tên ứng viên',
                icon: Icons.person_outline,
                readOnly: true,
              ),
              SizedBox(height: 12.h),

              CustomTextFieldWithLabel(
                labelTextColor: Colors.black87,
                controller: timeController,
                label: 'Thời gian',
                hintText: 'HH:MM DD/MM/YYYY',
                icon: Icons.access_time,
                readOnly: true,
              ),
              SizedBox(height: 12.h),

              CustomTextFieldWithLabel(
                labelTextColor: Colors.black87,
                controller: locationController,
                label: 'Địa điểm',
                hintText: 'Nhập địa điểm',
                icon: Icons.location_on_outlined,
                readOnly: true,
              ),
              SizedBox(height: 12.h),

              CustomTextFieldWithLabel(
                labelTextColor: Colors.black87,
                controller: interviewerController,
                label: 'Người phỏng vấn',
                hintText: 'Chưa có người phỏng vấn',
                icon: Icons.person_search_outlined,
                readOnly: true,
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
                readOnly: true,
                fillColor: Colors.white,
                borderColor: Colors.grey.shade300,
                hintText: "Không có ghi chú",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
