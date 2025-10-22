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
        idUser1: json['idUser1'],
        idUser2: json['idUser2'],
        status: json['status'],
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

  SocialConnectionModel copyWith({
    String? idUser1,
    String? idUser2,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialConnectionModel(
      idUser1: idUser1 ?? this.idUser1,
      idUser2: idUser2 ?? this.idUser2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'SocialConnectionModel($idUser1 <-> $idUser2, $status)';
}
