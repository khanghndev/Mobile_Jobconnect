class GroupReactionModel {
  final String idPost;
  final String idUser;
  final String reactionType;
  final DateTime createdAt;

  GroupReactionModel({
    required this.idPost,
    required this.idUser,
    required this.reactionType,
    required this.createdAt,
  });

  factory GroupReactionModel.fromJson(Map<String, dynamic> json) => GroupReactionModel(
        idPost: json['idPost'],
        idUser: json['idUser'],
        reactionType: json['reactionType'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idUser': idUser,
        'reactionType': reactionType,
        'createdAt': createdAt.toIso8601String(),
      };

  GroupReactionModel copyWith({
    String? idPost,
    String? idUser,
    String? reactionType,
    DateTime? createdAt,
  }) {
    return GroupReactionModel(
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      reactionType: reactionType ?? this.reactionType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'GroupReactionModel($reactionType on $idPost)';
}
