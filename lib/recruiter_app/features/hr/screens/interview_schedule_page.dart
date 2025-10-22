import 'package:flutter/material.dart';

class InterviewSchedulePage extends StatelessWidget {
  const InterviewSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch phỏng vấn'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCalendarSection(),
          const SizedBox(height: 24),
          _buildUpcomingInterviews(),
          const SizedBox(height: 24),
          _buildPastInterviews(),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch phỏng vấn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  'Calendar Widget',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingInterviews() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phỏng vấn sắp tới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInterviewList(true),
          ],
        ),
      ),
    );
  }

  Widget _buildPastInterviews() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phỏng vấn đã qua',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInterviewList(false),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewList(bool isUpcoming) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildInterviewCard(
          candidateName: 'Nguyễn Văn A',
          position: 'Lập trình viên Flutter',
          date: '15/03/2024',
          time: '09:00',
          type: 'Online',
          status: isUpcoming ? 'Sắp tới' : 'Đã hoàn thành',
          isUpcoming: isUpcoming,
        );
      },
    );
  }

  Widget _buildInterviewCard({
    required String candidateName,
    required String position,
    required String date,
    required String time,
    required String type,
    required String status,
    required bool isUpcoming,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUpcoming ? Colors.blue : Colors.grey,
          child: Icon(
            isUpcoming ? Icons.person : Icons.person_outline,
            color: Colors.white,
          ),
        ),
        title: Text(candidateName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(position),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$date $time',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.video_call, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  type,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUpcoming ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 4),
              TextButton(onPressed: () {}, child: const Text('Bắt đầu')),
            ],
          ],
        ),
      ),
    );
  }
}
