import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/resume/screens/Info/customize_style_screen.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<dynamic> workExperiences;
  final List<Education> educations;
  final List<String> skills;
  final String careerObjective;
  final bool isAIGenerated;

  const AdditionalInfoScreen({
    Key? key,
    required this.personalInfo,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.careerObjective,
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _certificatesController = TextEditingController();
  final _awardsController = TextEditingController();
  final _projectsController = TextEditingController();
  final _hobbiesController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAIGenerated) {
      _generateAdditionalInfo();
    }
  }

  Future<void> _generateAdditionalInfo() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      //   Implement actual AI API call
      // For now, we'll simulate an API call with a delay
      await Future.delayed(Duration(seconds: 2));

      // Generate additional info based on the user's profile
      final position = widget.personalInfo['position'] ?? 'professional';
      final skills = widget.skills.join(', ');

      setState(() {
        _certificatesController.text = '''
• Professional Certification in $position
• Advanced Training in ${skills.split(', ').first}
''';

        _awardsController.text = '''
• Outstanding Performance Award
• Employee of the Month
''';

        _projectsController.text = '''
• Led a team project in $position
• Developed innovative solutions using $skills
''';

        _hobbiesController.text = '''
• Professional networking
• Continuous learning in $position
• Industry research and development
''';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI has generated additional information!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate additional information. Please try again.',
          ),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CustomizeStyleScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: widget.careerObjective,
              certificates: _certificatesController.text,
              awards: _awardsController.text,
              projects: _projectsController.text,
              hobbies: _hobbiesController.text,
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  void _skipStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CustomizeStyleScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: widget.careerObjective,
              certificates: '',
              awards: '',
              projects: '',
              hobbies: '',
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Step 6/6: Additional Information (Optional)"),
      ),
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
                        "AI is helping you create your CV. You can edit the generated content or use AI suggestions.",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              "Add any additional information if available.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _certificatesController,
              decoration: InputDecoration(
                labelText: "Certificates (one per line)",
                border: OutlineInputBorder(),
                helperText: "List your professional certifications",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _awardsController,
              decoration: InputDecoration(
                labelText: "Awards (one per line)",
                border: OutlineInputBorder(),
                helperText: "List your professional awards and recognition",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _projectsController,
              decoration: InputDecoration(
                labelText: "Personal Projects (one per line)",
                border: OutlineInputBorder(),
                helperText: "List your significant projects",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _hobbiesController,
              decoration: InputDecoration(
                labelText: "Work-related Hobbies",
                border: OutlineInputBorder(),
                helperText: "List hobbies relevant to your profession",
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            if (widget.isAIGenerated)
              ElevatedButton.icon(
                icon:
                    _isGenerating
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? "Generating..." : "Generate with AI",
                ),
                onPressed: _isGenerating ? null : _generateAdditionalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text("Back"),
                ),
                TextButton(onPressed: _skipStep, child: Text("Skip")),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text("Create CV & Preview"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
