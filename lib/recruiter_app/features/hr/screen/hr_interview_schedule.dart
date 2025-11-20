import 'package:flutter/material.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/recruiter_app/services/interviewschedule_service.dart';
import 'edit_interview_schedule_screen.dart';

class HrInterviewSchedule extends StatefulWidget {
  const HrInterviewSchedule({super.key});

  @override
  State<HrInterviewSchedule> createState() =>
      _HrInterviewScheduleState();
}

class _HrInterviewScheduleState
    extends State<HrInterviewSchedule> {
  final InterviewScheduleService _scheduleService = InterviewScheduleService();
  List<InterviewScheduleModel> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Hàm load dữ liệu từ API (hoặc service) khi kéo xuống làm mới.
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _scheduleService.getAllInterviewSchedules();
      setState(() => _schedules = schedules);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm xoá lịch, chỉ cho phép xoá nếu lịch đã quá hạn (ngày phỏng vấn nhỏ hơn ngày hiện tại).
  Future<void> _deleteSchedule(String id) async {
    final schedule = _schedules.firstWhere((s) => s.idSchedule == id);
    final now = DateTime.now();
    final isExpired =
        schedule.interviewDate.isBefore(DateTime(now.year, now.month, now.day));

    if (!isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ cho phép xoá lịch đã quá hạn.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc muốn xoá lịch phỏng vấn này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xoá')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _scheduleService.deleteInterviewSchedule(id: id);
        // if (success.) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Đã xoá lịch phỏng vấn.')));
        //   _loadData();
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Xoá thất bại.')));
        // }
        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xoá lịch phỏng vấn.')));
          _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi xoá: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả lịch phỏng vấn'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _schedules.isEmpty
                ? const Center(child: Text('Không có lịch phỏng vấn nào.'))
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    itemCount: _schedules.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      final now = DateTime.now();
                      // Xét theo ngày (không tính giờ phút giây)
                      final isExpired = schedule.interviewDate
                          .isBefore(DateTime(now.year, now.month, now.day));
                      final isToday = _isSameDay(schedule.interviewDate, now);
                      final isYesterday =
                          _isSameDay(schedule.interviewDate, now.subtract(const Duration(days: 1)));
                      final isUpcoming = schedule.interviewDate
                          .isAfter(DateTime(now.year, now.month, now.day));
                      final daysLate = now
                          .difference(DateTime(schedule.interviewDate.year,
                              schedule.interviewDate.month,
                              schedule.interviewDate.day))
                          .inDays;
                      final daysToGo = DateTime(schedule.interviewDate.year,
                              schedule.interviewDate.month,
                              schedule.interviewDate.day)
                          .difference(DateTime(now.year, now.month, now.day))
                          .inDays;
                      final isOnline = (schedule.interviewMode
                              ?.toLowerCase()
                              .contains('online') ??
                          false);

                      final Color cardBg = isExpired
                          ? const Color(0xFFFFE5E5)
                          : (isOnline ? const Color(0xFFFFF9E5) : Colors.white);

                      Widget? statusLabel;
                      if (isExpired) {
                        statusLabel = isYesterday
                            ? _buildTag('Hôm qua', Colors.deepOrangeAccent, Icons.history)
                            : _buildTag('Quá hạn: $daysLate ngày', Colors.redAccent, Icons.warning_amber_rounded);
                      } else if (isToday) {
                        statusLabel = _buildTag('Hôm nay', Colors.green, Icons.today);
                      } else if (isUpcoming) {
                        statusLabel = _buildTag('Chuẩn bị: $daysToGo ngày', Colors.blueAccent, Icons.schedule);
                      }

                      return Material(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: cardBg,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withValues(alpha:0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.blueAccent.withValues(alpha:0.15),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (statusLabel != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: statusLabel,
                                      ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent.withValues(alpha:0.13),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          child: const Icon(Icons.event_available,
                                              color: Colors.blueAccent, size: 34),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Lịch phỏng vấn',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                      color: Colors.blueAccent)),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(_formatDate(
                                                      schedule.interviewDate),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black87)),
                                                  const SizedBox(width: 14),
                                                  const Icon(Icons.access_time,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(_formatHour(
                                                      schedule.interviewDate),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black87)),
                                                ],
                                              ),
                                              if (schedule.location != null &&
                                                  schedule.location!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 7),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.location_on,
                                                          size: 16,
                                                          color: Colors.redAccent),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                            "Địa chỉ: ${schedule.location!}",
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black87),
                                                            overflow:
                                                                TextOverflow.ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (schedule.interviewMode != null &&
                                                  schedule.interviewMode!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 7),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.computer,
                                                          size: 16,
                                                          color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          "Hình thức: ${schedule.interviewMode!}",
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black87)),
                                                    ],
                                                  ),
                                                ),
                                              if (schedule.interviewer != null &&
                                                  schedule.interviewer!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 7),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.person,
                                                          size: 16,
                                                          color: Colors.orange),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          "Người PV: ${schedule.interviewer!}",
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black87)),
                                                    ],
                                                  ),
                                                ),
                                              if (schedule.note != null &&
                                                  schedule.note!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 7),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.note,
                                                          size: 16,
                                                          color: Colors.purple),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                            "Ghi chú: ${schedule.note!}",
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black87)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                          ),
                                          icon: const Icon(Icons.edit,
                                              size: 20, color: Colors.white),
                                          label: const Text('Chỉnh sửa'),
                                          onPressed: isExpired
                                              ? null
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditInterviewScheduleScreen(
                                                              schedule:
                                                                  schedule),
                                                    ),
                                                  );
                                                },
                                        ),
                                        // ElevatedButton.icon(
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: Colors.blueAccent,
                                        //     foregroundColor: Colors.white,
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius:
                                        //           BorderRadius.circular(8),
                                        //     ),
                                        //     padding: const EdgeInsets.symmetric(
                                        //         horizontal: 12, vertical: 8),
                                        //   ),
                                        //   icon: const Icon(Icons.send,
                                        //       size: 20, color: Colors.white),
                                        //   label: const Text('Gửi lịch'),
                                        //   onPressed: isExpired
                                        //       ? null
                                        //       : () {
                                        //           ScaffoldMessenger.of(context)
                                        //               .showSnackBar(
                                        //                   const SnackBar(
                                        //                       content: Text(
                                        //                           'Đã gửi lịch cho ứng viên!')));
                                        //         },
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _deleteSchedule(schedule.idSchedule),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.red.withValues(alpha:0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.delete,
                                      color: Colors.red, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
    );
  }

  static Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatHour(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $ampm';
  }
}