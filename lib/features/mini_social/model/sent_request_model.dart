class SentRequestModel {
  final String idUser1; // người gửi
  final String idUser2; // người nhận
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String receiverName;
  final String receiverAvatar;

  SentRequestModel({
    required this.idUser1,
    required this.idUser2,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.receiverName,
    required this.receiverAvatar,
  });

  factory SentRequestModel.fromJson(Map<String, dynamic> json) {
    return SentRequestModel(
      idUser1: json['idUser1'] ?? '',
      idUser2: json['idUser2'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      receiverName: json['receiverName'] ?? '',
      receiverAvatar: json['receiverAvatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser1': idUser1,
      'idUser2': idUser2,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
    };
  }
}
