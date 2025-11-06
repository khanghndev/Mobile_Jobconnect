class CandidateInfoModel {
  final String idUser;
  final String? workPosition;
  final double? ratingScore;
  final String? universityName;
  final String? educationLevel;
  final int? experienceYears;
  final String? skills;
  final String? freeTime; 
  final String? portfolioUrl; 

  CandidateInfoModel({
    required this.idUser,
    this.workPosition,
    this.ratingScore,
    this.universityName,
    this.educationLevel,
    this.experienceYears,
    this.skills,
    this.freeTime,
    this.portfolioUrl,
  });

  factory CandidateInfoModel.fromJson(Map<String, dynamic> json) {
    return CandidateInfoModel(
      idUser: json['idUser'] as String,
      workPosition: json['workPosition'] as String?,
      ratingScore: (json['ratingScore'] as num?)?.toDouble(),
      universityName: json['universityName'] as String?,
      educationLevel: json['educationLevel'] as String?,
      experienceYears: json['experienceYears'] as int?,
      skills: json['skills'] as String?,
      freeTime: json['freeTime'] as String?,
      portfolioUrl: json['portfolioUrl'] as String?,
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
      'freeTime': freeTime,
      'portfolioUrl': portfolioUrl,
    };
  }

  CandidateInfoModel copyWith({
    String? idUser,
    String? workPosition,
    double? ratingScore,
    String? universityName,
    String? educationLevel,
    int? experienceYears,
    String? skills,
    String? freeTime,
    String? portfolioUrl,
  }) {
    return CandidateInfoModel(
      idUser: idUser ?? this.idUser,
      workPosition: workPosition ?? this.workPosition,
      ratingScore: ratingScore ?? this.ratingScore,
      universityName: universityName ?? this.universityName,
      educationLevel: educationLevel ?? this.educationLevel,
      experienceYears: experienceYears ?? this.experienceYears,
      skills: skills ?? this.skills,
      freeTime: freeTime ?? this.freeTime,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    );
  }

  @override
  String toString() {
    return 'CandidateInfoModel(idUser: $idUser, workPosition: $workPosition, ratingScore: $ratingScore, universityName: $universityName, educationLevel: $educationLevel, experienceYears: $experienceYears, skills: $skills, freeTime: $freeTime, portfolioUrl: $portfolioUrl)';
  }
}