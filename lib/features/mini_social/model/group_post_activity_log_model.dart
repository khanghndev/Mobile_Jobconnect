class GroupPostActivityLogModel {
  final String idLog;
  final String idPost;
  final String idUser;
  final String activityType; // view, share, report
  final DateTime createdAt;

  GroupPostActivityLogModel({
    required this.idLog,
    required this.idPost,
    required this.idUser,
    required this.activityType,
    required this.createdAt,
  });

  factory GroupPostActivityLogModel.fromJson(Map<String, dynamic> json) =>
      GroupPostActivityLogModel(
        idLog: json['idLog'],
        idPost: json['idPost'],
        idUser: json['idUser'],
        activityType: json['activityType'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idLog': idLog,
        'idPost': idPost,
        'idUser': idUser,
        'activityType': activityType,
        'createdAt': createdAt.toIso8601String(),
      };

  GroupPostActivityLogModel copyWith({
    String? idLog,
    String? idPost,
    String? idUser,
    String? activityType,
    DateTime? createdAt,
  }) {
    return GroupPostActivityLogModel(
      idLog: idLog ?? this.idLog,
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      activityType: activityType ?? this.activityType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'GroupPostActivityLogModel($activityType, $idPost, $idUser)';
}
