class SavedResumeModel {
  final String idSave;
  final String idRecruiter;
  final String idCandidate;
  final DateTime savedAt;

  SavedResumeModel({
    required this.idSave,
    required this.idRecruiter,
    required this.idCandidate,
    required this.savedAt,
  });

  factory SavedResumeModel.fromJson(Map<String, dynamic> json) => SavedResumeModel(
        idSave: json['idSave'] as String,
        idRecruiter: json['idRecruiter'] as String,
        idCandidate: json['idCandidate'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'idSave': idSave,
        'idRecruiter': idRecruiter,
        'idCandidate': idCandidate,
        'savedAt': savedAt.toIso8601String(),
      };

  SavedResumeModel copyWith({
    String? idSave,
    String? idRecruiter,
    String? idCandidate,
    DateTime? savedAt,
  }) {
    return SavedResumeModel(
      idSave: idSave ?? this.idSave,
      idRecruiter: idRecruiter ?? this.idRecruiter,
      idCandidate: idCandidate ?? this.idCandidate,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  String toString() => 'SavedResumeModel(idSave: $idSave, recruiter: $idRecruiter, candidate: $idCandidate, savedAt: $savedAt)';
}
