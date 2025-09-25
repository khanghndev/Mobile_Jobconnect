class ResumeSkill {
  final String idResume;
  final String skill;
  final String? proficiency;
  // final Resume? resume;

  ResumeSkill({
    required this.idResume,
    required this.skill,
    this.proficiency,
    // this.resume,
  });

  factory ResumeSkill.fromJson(Map<String, dynamic> json) {
    return ResumeSkill(
      idResume: json['idResume'],
      skill: json['skill'],
      proficiency: json['proficiency'],
      // resume: json['resume'] != null ? Resume.fromJson(json['resume']) : null,
    );
  }
}
