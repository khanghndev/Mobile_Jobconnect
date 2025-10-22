import 'package:flutter/material.dart';

class RecentActivitiesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivitiesScreen({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoạt động gần đây'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: activities.isEmpty
          ? const Center(
              child: Text(
                'Không có hoạt động nào gần đây.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      size: 24,
                      color: activity['color'] as Color,
                    ),
                  ),
                  title: Text(
                    activity['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    activity['time'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Xử lý khi nhấn vào một hoạt động (nếu cần)
                  },
                );
              },
            ),
    );
  }
}