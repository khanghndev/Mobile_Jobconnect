// Request model
class SocialConnectionRequest {
  final String fromUserId;
  final String toUserId;

  SocialConnectionRequest({
    required this.fromUserId,
    required this.toUserId,
  });

  Map<String, dynamic> toJson() => {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
      };
}

// Response model
class SocialConnectionModel {
  final String idUser1;
  final String idUser2;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialConnectionModel({
    required this.idUser1,
    required this.idUser2,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialConnectionModel.fromJson(Map<String, dynamic> json) =>
      SocialConnectionModel(
        idUser1: json['idUser1'] ?? '',
        idUser2: json['idUser2'] ?? '',
        status: json['status'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'idUser1': idUser1,
        'idUser2': idUser2,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}