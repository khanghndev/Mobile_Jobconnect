class InterviewScheduleModel {
  final String idSchedule;
  final String idJobPost;
  final String idUser;
  final DateTime interviewDate;
  final String? interviewMode;
  final String? location;
  final String? interviewer;
  final String? note;

  InterviewScheduleModel({
    required this.idSchedule,
    required this.idJobPost,
    required this.idUser,
    required this.interviewDate,
    this.interviewMode,
    this.location,
    this.interviewer,
    this.note,
  });

  factory InterviewScheduleModel.fromJson(Map<String, dynamic> json) {
    return InterviewScheduleModel(
      idSchedule: json['idSchedule'] as String,
      idJobPost: json['idJobPost'] as String,
      idUser: json['idUser'] as String,
      interviewDate: DateTime.parse(json['interviewDate'] as String),
      interviewMode: json['interviewMode'] as String?,
      location: json['location'] as String?,
      interviewer: json['interviewer'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'idSchedule': idSchedule,
        'idJobPost': idJobPost,
        'idUser': idUser,
        'interviewDate': interviewDate.toIso8601String(),
        'interviewMode': interviewMode,
        'location': location,
        'interviewer': interviewer,
        'note': note,
      };

  @override
  String toString() {
    return 'InterviewScheduleModel($idSchedule) for job=$idJobPost user=$idUser at $interviewDate';
  }
}