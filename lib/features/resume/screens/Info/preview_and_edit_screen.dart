import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/download_screen.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';
import 'package:job_connect/features/resume/screens/Info/work_experience_screen.dart';

class PreviewAndEditScreen extends StatefulWidget {
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

  const PreviewAndEditScreen({
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

  @override
  _PreviewAndEditScreenState createState() => _PreviewAndEditScreenState();
}

class _PreviewAndEditScreenState extends State<PreviewAndEditScreen> {
  late TextEditingController _summaryController;
  late TextEditingController _experienceController;
  late TextEditingController _educationController;
  late TextEditingController _skillsController;
  late TextEditingController _additionalInfoController;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _summaryController = TextEditingController(text: widget.careerObjective);
    _experienceController = TextEditingController(
      text: _formatExperiences(widget.workExperiences),
    );
    _educationController = TextEditingController(
      text: _formatEducations(widget.educations),
    );
    _skillsController = TextEditingController(text: widget.skills.join('\n• '));
    _additionalInfoController = TextEditingController(
      text: _formatAdditionalInfo(),
    );
  }

  String _formatExperiences(List<dynamic> experiences) {
    return experiences
        .map((exp) {
          return '''
• ${exp['position']} at ${exp['company']}
  ${exp['startDate']} - ${exp['endDate']}
  ${exp['description']}
''';
        })
        .join('\n');
  }

  String _formatEducations(List<Education> educations) {
    return educations
        .map((edu) {
          return '''
• ${edu.degree}
  ${edu.institutionName}
  ${edu.studyTime}
  ${edu.gpaAchievements}
''';
        })
        .join('\n');
  }

  String _formatAdditionalInfo() {
    return '''
Certificates:
${widget.certificates}

Awards:
${widget.awards}

Projects:
${widget.projects}

Hobbies:
${widget.hobbies}
''';
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _rewriteSectionWithAI(
    TextEditingController controller,
    String sectionName,
  ) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // TODO: Implement actual AI API call
      // For now, we'll simulate an API call with a delay
      await Future.delayed(Duration(seconds: 2));

      // Generate improved content based on the section and tone
      final currentText = controller.text;
      final improvedText = await _generateImprovedContent(
        currentText,
        sectionName,
        widget.tone,
      );

      setState(() {
        controller.text = improvedText;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI has improved the $sectionName section')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to improve section. Please try again.')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<String> _generateImprovedContent(
    String currentText,
    String sectionName,
    String tone,
  ) async {
    // TODO: Implement actual AI API call
    // This is a placeholder that simulates AI improvement
    return '''
[Improved $sectionName in $tone tone]
$currentText

[Enhanced with professional language and better structure]
''';
  }

  void _finalizeAndSave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DownloadScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: widget.educations,
              skills: widget.skills,
              careerObjective: _summaryController.text,
              certificates: widget.certificates,
              awards: widget.awards,
              projects: widget.projects,
              hobbies: widget.hobbies,
              template: widget.template,
              tone: widget.tone,
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview & Edit CV"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "Save and Finalize",
            onPressed: _finalizeAndSave,
          ),
        ],
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
                        "AI is helping you create your CV. You can edit any section or use AI to improve the content.",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            _buildEditableSection(
              title: "Career Objective / Summary",
              controller: _summaryController,
              onAIRewrite:
                  () => _rewriteSectionWithAI(
                    _summaryController,
                    "Career Objective",
                  ),
            ),
            SizedBox(height: 16),
            _buildEditableSection(
              title: "Work Experience",
              controller: _experienceController,
              onAIRewrite:
                  () => _rewriteSectionWithAI(
                    _experienceController,
                    "Work Experience",
                  ),
            ),
            SizedBox(height: 16),
            _buildEditableSection(
              title: "Education",
              controller: _educationController,
              onAIRewrite:
                  () =>
                      _rewriteSectionWithAI(_educationController, "Education"),
            ),
            SizedBox(height: 16),
            _buildEditableSection(
              title: "Skills",
              controller: _skillsController,
              onAIRewrite:
                  () => _rewriteSectionWithAI(_skillsController, "Skills"),
            ),
            SizedBox(height: 16),
            _buildEditableSection(
              title: "Additional Information",
              controller: _additionalInfoController,
              onAIRewrite:
                  () => _rewriteSectionWithAI(
                    _additionalInfoController,
                    "Additional Information",
                  ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _finalizeAndSave,
              child: Text("Finalize and Save CV"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required TextEditingController controller,
    VoidCallback? onAIRewrite,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Content for $title",
              ),
            ),
            if (onAIRewrite != null) ...[
              SizedBox(height: 8),
              TextButton.icon(
                icon:
                    _isGenerating
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                        : Icon(Icons.auto_fix_high, size: 18),
                label: Text(
                  _isGenerating
                      ? "Improving..."
                      : "Improve with AI / Make more professional",
                ),
                onPressed: _isGenerating ? null : onAIRewrite,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
