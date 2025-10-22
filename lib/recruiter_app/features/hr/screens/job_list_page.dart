import 'package:flutter/material.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildJobCard(
            title:
                index == 0
                    ? 'Flutter Developer'
                    : index == 1
                    ? 'UI/UX Designer'
                    : index == 2
                    ? 'Product Manager'
                    : index == 3
                    ? 'Marketing Manager'
                    : 'Business Analyst',
            applicants:
                index == 0
                    ? 25
                    : index == 1
                    ? 18
                    : index == 2
                    ? 32
                    : index == 3
                    ? 15
                    : 20,
            status:
                index == 0
                    ? 'Đang tuyển'
                    : index == 1
                    ? 'Đã đóng'
                    : index == 2
                    ? 'Đang tuyển'
                    : index == 3
                    ? 'Đã đóng'
                    : 'Đang tuyển',
            postedDate:
                index == 0
                    ? '2 ngày trước'
                    : index == 1
                    ? '1 tuần trước'
                    : index == 2
                    ? '2 tuần trước'
                    : index == 3
                    ? '3 ngày trước'
                    : '1 ngày trước',
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required int applicants,
    required String status,
    required String postedDate,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đăng $postedDate',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == 'Đang tuyển'
                            // ignore: deprecated_member_use
                            ? Colors.green.withValues(alpha:0.1)
                            // ignore: deprecated_member_use
                            : Colors.red.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Đang tuyển' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.people_outline, '$applicants ứng viên'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.access_time, postedDate),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Xem ứng viên')),
                const SizedBox(width: 8),
                TextButton(onPressed: () {}, child: const Text('Chỉnh sửa')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Đóng tuyển',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
