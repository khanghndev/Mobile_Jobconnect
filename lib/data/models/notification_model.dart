class NotificationModel {
  final String idNotification;
  final String idUser;
  final String title;
  final String type; // Cập nhật ứng tuyển, Phỏng vấn, Việc làm mới
  final DateTime dateTime;
  final String status; // Đã gửi, Lên lịch, Chờ xử lý
  final String actionUrl;
  final DateTime createdAt;
  int isRead;

  NotificationModel({
    required this.idNotification,
    required this.idUser,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.status,
    required this.actionUrl,
    DateTime? createdAt,
    this.isRead = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification: json['idNotification'],
      idUser: json['idUser'],
      title: json['title'],
      type: json['type'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
      actionUrl: json['actionUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idNotification': idNotification,
      'idUser': idUser,
      'title': title,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
