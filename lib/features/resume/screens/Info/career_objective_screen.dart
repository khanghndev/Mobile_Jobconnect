import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/resume/screens/Info/additional_info_screen.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

class CareerObjectiveScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<dynamic> workExperiences;
  final List<Education> educations;
  final List<String> skills;
  final bool isAIGenerated;

  const CareerObjectiveScreen({
    Key? key,
    required this.personalInfo,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _CareerObjectiveScreenState createState() => _CareerObjectiveScreenState();
}

class _CareerObjectiveScreenState extends State<CareerObjectiveScreen> {
  final _objectiveController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAIGenerated) {
      _generateByAI();
    }
  }

  Future<void> _generateByAI() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      //   Implement actual AI API call
      // For now, we'll simulate an API call with a delay
      await Future.delayed(Duration(seconds: 2));

      // Generate a career objective based on the user's profile
      final position = widget.personalInfo['position'] ?? 'professional';
      final experience = widget.workExperiences.length;
      final skills = widget.skills.join(', ');

      final generatedObjective = '''
Experienced $position with $experience years of professional experience. 
Skilled in $skills. Seeking to leverage my expertise in a challenging role 
that allows for professional growth and contribution to organizational success.
''';

      setState(() {
        _objectiveController.text = generatedObjective;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI has generated your career objective!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate career objective. Please try again.',
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
            (_) => AdditionalInfoScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: _objectiveController.text,
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
            (_) => AdditionalInfoScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: '',
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Step 5/6: Career Objective (Optional)")),
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
              "Write your career objective or personal summary. Or let AI help you!",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _objectiveController,
              decoration: InputDecoration(
                labelText: "Career Objective/Personal Summary",
                border: OutlineInputBorder(),
                helperText:
                    "Describe your career goals and professional summary",
              ),
              maxLines: 8,
              minLines: 5,
            ),
            SizedBox(height: 20),
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
              label: Text(_isGenerating ? "Generating..." : "Generate with AI"),
              onPressed: _isGenerating ? null : _generateByAI,
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
                ElevatedButton(onPressed: _nextStep, child: Text("Continue")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
