class InterviewSchedule {
  final String idSchedule;
  final String idJobApp;
  final DateTime interviewDate;
  final String? interviewMode;
  final String? location;
  final String? interviewer;
  final String? note;

  InterviewSchedule({
    required this.idSchedule,
    required this.idJobApp,
    required this.interviewDate,
    this.interviewMode,
    this.location,
    this.interviewer,
    this.note,
  });

  factory InterviewSchedule.fromJson(Map<String, dynamic> json) {
    return InterviewSchedule(
      idSchedule: json['idSchedule'] as String,
      idJobApp: json['idJobApp'] as String,
      interviewDate: DateTime.parse(json['interviewDate'] as String),
      interviewMode: json['interviewMode'] as String?,
      location: json['location'] as String?,
      interviewer: json['interviewer'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'idSchedule': idSchedule,
        'idJobApp': idJobApp,
        'interviewDate': interviewDate.toIso8601String(),
        'interviewMode': interviewMode,
        'location': location,
        'interviewer': interviewer,
        'note': note,
      };
}
