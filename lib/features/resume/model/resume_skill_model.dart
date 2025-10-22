class ResumeSkillModel {
  final String idResume;
  final String skill;
  final String? proficiency;

  ResumeSkillModel({
    required this.idResume,
    required this.skill,
    this.proficiency,
  });

  factory ResumeSkillModel.fromJson(Map<String, dynamic> json) {
    return ResumeSkillModel(
      idResume: json['idResume'],
      skill: json['skill'],
      proficiency: json['proficiency'],
    );
  }
}
