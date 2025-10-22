class SaveCandidateModel {
  final String idUserRecruiter;
  final String idUserCandidate;
  final DateTime savedAt;
  final String? note;

  SaveCandidateModel({
    required this.idUserRecruiter,
    required this.idUserCandidate,
    required this.savedAt,
    this.note,
  });

  factory SaveCandidateModel.fromJson(Map<String, dynamic> json) => SaveCandidateModel(
        idUserRecruiter: json['idUserRecruiter'] as String,
        idUserCandidate: json['idUserCandidate'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'idUserRecruiter': idUserRecruiter,
        'idUserCandidate': idUserCandidate,
        'savedAt': savedAt.toIso8601String(),
        'note': note,
      };

  SaveCandidateModel copyWith({
    String? idUserRecruiter,
    String? idUserCandidate,
    DateTime? savedAt,
    String? note,
  }) {
    return SaveCandidateModel(
      idUserRecruiter: idUserRecruiter ?? this.idUserRecruiter,
      idUserCandidate: idUserCandidate ?? this.idUserCandidate,
      savedAt: savedAt ?? this.savedAt,
      note: note ?? this.note,
    );
  }

  @override
  String toString() => 'SaveCandidateModel($idUserRecruiter → $idUserCandidate)';
}