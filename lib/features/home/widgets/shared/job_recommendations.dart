import 'package:flutter/material.dart';

class JobRecommendationsScreen extends StatelessWidget {
  final List<Map<String, String>> jobRecommendations = [
    {
      'title': 'Software Engineer',
      'company': 'TechCorp',
      'location': 'San Francisco, CA',
    },
    {
      'title': 'Product Manager',
      'company': 'Innovatech',
      'location': 'New York, NY',
    },
    {
      'title': 'UI/UX Designer',
      'company': 'DesignPro',
      'location': 'Austin, TX',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Recommendations')),
      body: ListView.builder(
        itemCount: jobRecommendations.length,
        itemBuilder: (context, index) {
          final job = jobRecommendations[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(job['title'] ?? ''),
              subtitle: Text('${job['company']} - ${job['location']}'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Handle job tap
              },
            ),
          );
        },
      ),
    );
  }
}
