import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/recruiter_app/services/interviewschedule_service.dart';

class EditInterviewScheduleScreen extends StatefulWidget {
  final InterviewScheduleModel schedule;

  const EditInterviewScheduleScreen({super.key, required this.schedule});

  @override
  State<EditInterviewScheduleScreen> createState() => _EditInterviewScheduleScreenState();
}

class _EditInterviewScheduleScreenState extends State<EditInterviewScheduleScreen> {
  final InterviewScheduleService _interviewScheduleService = InterviewScheduleService();
  
  late TextEditingController _locationController;
  late TextEditingController _interviewerController;
  late TextEditingController _noteController;
  late TextEditingController _modeController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.schedule.location);
    _interviewerController = TextEditingController(text: widget.schedule.interviewer);
    _noteController = TextEditingController(text: widget.schedule.note);
    _modeController = TextEditingController(text: widget.schedule.interviewMode);
    _selectedDateTime = widget.schedule.interviewDate;
    _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDateTime));
    _timeController = TextEditingController(text: DateFormat('HH:mm').format(_selectedDateTime));
  }

  @override
  void dispose() {
    _locationController.dispose();
    _interviewerController.dispose();
    _noteController.dispose();
    _modeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(date.year, date.month, date.day, _selectedDateTime.hour, _selectedDateTime.minute);
        _dateController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day, time.hour, time.minute);
        _timeController.text = DateFormat('HH:mm').format(_selectedDateTime);
      });
    }
  }

  Future<void> _saveChanges() async {
    // final InterviewScheduleModel schedule = InterviewScheduleModel(
    //   idSchedule: id,
    //   idJobPost: id, 
    //   location: _locationController.text.trim(),
    //   interviewMode: _modeController.text.trim(),
    //   interviewer: _interviewerController.text.trim(),
    //   note: _noteController.text.trim(),
    //   interviewDate: _selectedDateTime,
    // );

    // final success = await _interviewScheduleService.updateInterviewSchedule(schedule: schedule);
    // if (success.idSchedule.isNotEmpty) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Đã lưu thay đổi.'), backgroundColor: Colors.green,),
    //   );
    //   await Future.delayed(const Duration(seconds: 2));
    //   // ignore: use_build_context_synchronously
    //   Navigator.pop(context);
    // } else {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Cập nhật thất bại.'), backgroundColor: Colors.red),
    //   );
    // }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa lịch phỏng vấn'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(alignment: Alignment.center,
                child: const Text(
                  ' LỊCH PHỎNG VẤN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(_locationController, 'Địa điểm', Icons.location_on),
              const SizedBox(height: 16),
              _buildInputField(_modeController, 'Hình thức (Online/Offline)', Icons.computer),
              const SizedBox(height: 16),
              _buildInputField(_interviewerController, 'Người phỏng vấn', Icons.person),
              const SizedBox(height: 16),
              _buildInputField(_noteController, 'Ghi chú', Icons.note_alt, maxLines: 3),
              const SizedBox(height: 24),
              const Text('Ngày phỏng vấn', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildInputField(_dateController, '', Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Giờ phỏng vấn', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: _buildInputField(_timeController, '', Icons.access_time),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Lưu thay đổi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: Colors.indigoAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F7),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15, color: Colors.black87),
    );
  }
}