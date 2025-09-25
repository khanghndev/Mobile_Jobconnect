class CandidateInfo {
  final String? idUser;
  final String? workPosition;
  final double? ratingScore;
  final String? universityName;
  final String? educationLevel;
  final int? experienceYears;
  final String? skills;

  CandidateInfo({
    this.idUser,
    this.workPosition,
    this.ratingScore,
    this.universityName,
    this.educationLevel,
    this.experienceYears,
    this.skills,
  });

  factory CandidateInfo.fromJson(Map<String, dynamic> json) {
    return CandidateInfo(
      idUser: json['idUser'] as String?,
      workPosition: json['workPosition'] as String?,
      ratingScore: (json['ratingScore'] as num?)?.toDouble(),
      universityName: json['universityName'] as String?,
      educationLevel: json['educationLevel'] as String?,
      experienceYears: json['experienceYears'] as int?,
      skills: json['skills'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'workPosition': workPosition,
      'ratingScore': ratingScore,
      'universityName': universityName,
      'educationLevel': educationLevel,
      'experienceYears': experienceYears,
      'skills': skills,
    };
  }

  @override
  String toString() {
    return 'CandidateInfo(idUser: $idUser, workPosition: $workPosition, ratingScore: $ratingScore, universityName: $universityName, educationLevel: $educationLevel, experienceYears: $experienceYears, skills: $skills)';
  }
}
