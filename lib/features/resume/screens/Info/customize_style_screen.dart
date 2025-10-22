import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/preview_and_edit_screen.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

class CustomizeStyleScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<dynamic> workExperiences;
  final List<Education> educations;
  final List<String> skills;
  final String careerObjective;
  final String certificates;
  final String awards;
  final String projects;
  final String hobbies;
  final bool isAIGenerated;

  const CustomizeStyleScreen({
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
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _CustomizeStyleScreenState createState() => _CustomizeStyleScreenState();
}

class _CustomizeStyleScreenState extends State<CustomizeStyleScreen> {
  String? _selectedTemplate = 'Template 1';
  List<String> _templates = [
    'Template 1',
    'Template 2',
    'Template 3 (Premium)',
  ];

  String? _selectedTone = 'Professional';
  List<String> _tones = ['Professional', 'Creative', 'Minimalist', 'Modern'];

  void _previewCV() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PreviewAndEditScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: widget.careerObjective,
              certificates: widget.certificates,
              awards: widget.awards,
              projects: widget.projects,
              hobbies: widget.hobbies,
              template: _selectedTemplate ?? 'Template 1',
              tone: _selectedTone ?? 'Professional',
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  void _skipStyleCustomization() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PreviewAndEditScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: widget.careerObjective,
              certificates: widget.certificates,
              awards: widget.awards,
              projects: widget.projects,
              hobbies: widget.hobbies,
              template: 'Template 1',
              tone: 'Professional',
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customize CV Style (Optional)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.isAIGenerated)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 16),
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
                        "AI is helping you create your CV. Choose a style that best represents your professional profile.",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              "Select CV Template:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTemplate,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                helperText: "Choose a template that matches your industry",
              ),
              items:
                  _templates.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTemplate = newValue;
                });
              },
            ),
            SizedBox(height: 24),
            Text(
              "Select Writing Tone:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                helperText: "Choose a tone that reflects your personality",
              ),
              items:
                  _tones.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTone = newValue;
                });
              },
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Back"),
                ),
                TextButton(
                  onPressed: _skipStyleCustomization,
                  child: Text("Use Default"),
                ),
                ElevatedButton(
                  onPressed: _previewCV,
                  child: Text("Preview CV"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
