import 'dart:convert';

class WorkScheduleModel {
  final String? idSchedule;
  final String? idJobPost;
  final String? scheduleType;
  final String? startTime;
  final String? endTime;
  final String? workingDays;
  final int? hoursPerDay;
  final int? daysPerWeek;
  final bool? isFlexible;
  final String? notes;

  WorkScheduleModel({
    this.idSchedule,
    this.idJobPost,
    this.scheduleType,
    this.startTime,
    this.endTime,
    this.workingDays,
    this.hoursPerDay,
    this.daysPerWeek,
    this.isFlexible,
    this.notes,
  });

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkScheduleModel(
      idSchedule: json['idSchedule'] as String?,
      idJobPost: json['idJobPost'] as String?,
      scheduleType: json['scheduleType'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      workingDays: json['workingDays'] as String?,
      hoursPerDay: json['hoursPerDay'] as int?,
      daysPerWeek: json['daysPerWeek'] as int?,
      isFlexible: json['isFlexible'] as bool?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSchedule': idSchedule,
      'idJobPost': idJobPost,
      'scheduleType': scheduleType,
      'startTime': startTime,
      'endTime': endTime,
      'workingDays': workingDays,
      'hoursPerDay': hoursPerDay,
      'daysPerWeek': daysPerWeek,
      'isFlexible': isFlexible,
      'notes': notes,
    };
  }

  WorkScheduleModel copyWith({
    String? idSchedule,
    String? idJobPost,
    String? scheduleType,
    String? startTime,
    String? endTime,
    String? workingDays,
    int? hoursPerDay,
    int? daysPerWeek,
    bool? isFlexible,
    String? notes,
  }) {
    return WorkScheduleModel(
      idSchedule: idSchedule ?? this.idSchedule,
      idJobPost: idJobPost ?? this.idJobPost,
      scheduleType: scheduleType ?? this.scheduleType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      workingDays: workingDays ?? this.workingDays,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      isFlexible: isFlexible ?? this.isFlexible,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}