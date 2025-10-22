import 'package:flutter/material.dart';
import 'package:job_connect/config/utils/image_url.dart';

class SavedJobsScreen extends StatelessWidget {
  final String idUser;
  const SavedJobsScreen({super.key, required this.idUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Việc làm đã lưu'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [_buildSavedJobsList()],
      ),
    );
  }

  Widget _buildSavedJobsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildSavedJobCard(
          title: 'Lập trình viên Flutter',
          company: 'Công ty ABC',
          location: 'Hà Nội',
          salary: '15-25 triệu',
          type: 'Toàn thời gian',
          postedDate: '2 ngày trước',
          logoUrl: '',
          isExpired: index == 2,
        );
      },
    );
  }

  Widget _buildSavedJobCard({
    required String title,
    required String company,
    required String location,
    required String salary,
    required String type,
    required String postedDate,
    required String logoUrl,
    bool isExpired = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: ImageUtils.getImageProvider(logoUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark),
                      color: Colors.blue,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.location_on, location),
                    _buildInfoChip(Icons.attach_money, salary),
                    _buildInfoChip(Icons.work, type),
                    _buildInfoChip(Icons.access_time, postedDate),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isExpired ? null : () {},
                      child: const Text('Ứng tuyển'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpired)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Đã hết hạn',
                  style: TextStyle(color: Colors.red[900], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
