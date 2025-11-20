import 'dart:convert';

class SkillModel {
  final String? idJobPost;
  final String? skillName;
  final String? skillLevel;
  final bool? isRequired;

  SkillModel({
    this.idJobPost,
    this.skillName,
    this.skillLevel,
    this.isRequired,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      idJobPost: json['idJobPost'] as String?,
      skillName: json['skillName'] as String?,
      skillLevel: json['skillLevel'] as String?,
      isRequired: json['isRequired'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idJobPost': idJobPost,
      'skillName': skillName,
      'skillLevel': skillLevel,
      'isRequired': isRequired,
    };
  }

  SkillModel copyWith({
    String? idJobPost,
    String? skillName,
    String? skillLevel,
    bool? isRequired,
  }) {
    return SkillModel(
      idJobPost: idJobPost ?? this.idJobPost,
      skillName: skillName ?? this.skillName,
      skillLevel: skillLevel ?? this.skillLevel,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}