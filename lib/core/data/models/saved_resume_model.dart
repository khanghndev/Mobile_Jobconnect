class SavedResume {
  final String idSave;
  final String idRecruiter;
  final String idCandidate;
  final DateTime savedAt;

  SavedResume({
    required this.idSave,
    required this.idRecruiter,
    required this.idCandidate,
    required this.savedAt,
  });

  factory SavedResume.fromJson(Map<String, dynamic> json) {
    return SavedResume(
      idSave: json['idSave'] as String,
      idRecruiter: json['idRecruiter'] as String,
      idCandidate: json['idCandidate'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'idSave': idSave,
    'idRecruiter': idRecruiter,
    'idCandidate': idCandidate,
    'savedAt': savedAt.toIso8601String(),
  };
}
