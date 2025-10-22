import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

class DownloadScreen extends StatelessWidget {
  final Map<String, dynamic> personalInfo;
  final List<dynamic> workExperiences;
  final List<Education> educations;
  final List<String> skills;
  final String careerObjective;
  final String certificates;
  final String awards;
  final String projects;
  final String hobbies;
  final String template;
  final String tone;
  final bool isAIGenerated;

  const DownloadScreen({
    Key? key,
    required this.personalInfo,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.careerObjective,
    required this.certificates,
    required this.awards,
    required this.projects,
    required this.hobbies,
    required this.template,
    required this.tone,
    this.isAIGenerated = false,
  }) : super(key: key);

  Future<void> _downloadCV(BuildContext context, String format) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Preparing to download $format...")));

    try {
      // TODO: Implement actual file generation
      // 1. Call backend API to generate file and return URL or file bytes
      // 2. Or generate file on client:
      //    - Get CV data from widget properties
      //    - Use library (e.g., `pdf` for PDF, `docx_template` for DOCX) to create file
      //    - Save file to temp directory:
      //      final directory = await getApplicationDocumentsDirectory();
      //      final path = '${directory.path}/my_cv.$format';
      //      File file = File(path);
      //      if (format == 'pdf') {
      //        final pdf = pw.Document();
      //        pdf.addPage(pw.Page(...)); // Add content
      //        await file.writeAsBytes(await pdf.save());
      //      } else if (format == 'docx') {
      //        // Use docx library
      //      }
      //    - Open file:
      //      OpenFile.open(path);

      // Simulate file generation
      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$format downloaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to download $format. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete CV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                "Congratulations! Your CV is ready.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Your CV has been saved to your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (isAIGenerated) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your CV was created with AI assistance. You can download it in your preferred format.",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Download PDF"),
                onPressed: () => _downloadCV(context, 'pdf'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.description),
                label: Text("Download DOCX"),
                onPressed: () => _downloadCV(context, 'docx'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text("Return to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
