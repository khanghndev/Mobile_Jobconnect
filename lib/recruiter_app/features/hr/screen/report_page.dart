import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummarySection(),
          const SizedBox(height: 24),
          _buildChartSection(),
          const SizedBox(height: 24),
          _buildDetailedReportSection(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard(
                  'Tổng số ứng viên',
                  '154',
                  Icons.people_outline,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Công việc đang tuyển',
                  '32',
                  Icons.work_outline,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'Đã phỏng vấn',
                  '78',
                  Icons.record_voice_over_outlined,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Đã tuyển dụng',
                  '23',
                  Icons.check_circle_outline,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê theo tháng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Biểu đồ thống kê',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo cáo chi tiết',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportItem(
              'Tỷ lệ ứng viên theo ngành nghề',
              'Xem chi tiết',
              Icons.pie_chart_outline,
            ),
            const Divider(),
            _buildReportItem(
              'Thời gian tuyển dụng trung bình',
              'Xem chi tiết',
              Icons.timeline,
            ),
            const Divider(),
            _buildReportItem(
              'Chi phí tuyển dụng',
              'Xem chi tiết',
              Icons.attach_money,
            ),
            const Divider(),
            _buildReportItem(
              'Hiệu quả kênh tuyển dụng',
              'Xem chi tiết',
              Icons.analytics_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String title, String action, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: TextButton(onPressed: () {}, child: Text(action)),
    );
  }
}