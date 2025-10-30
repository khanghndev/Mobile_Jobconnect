class GroupReactionModel {
  final String idReaction;
  final String entityType;
  final String entityId;
  final String idUser;
  final String userName;
  final String userAvatar;
  final String reaction;
  final DateTime createdAt;

  GroupReactionModel({
    required this.idReaction,
    required this.entityType,
    required this.entityId,
    required this.idUser,
    required this.userName,
    required this.userAvatar,
    required this.reaction,
    required this.createdAt,
  });

  factory GroupReactionModel.fromJson(Map<String, dynamic> json) => GroupReactionModel(
        idReaction: json['idReaction'] ?? '',
        entityType: json['entityType'] ?? '',
        entityId: json['entityId'] ?? '',
        idUser: json['idUser'] ?? '',
        userName: json['userName'] ?? '',
        userAvatar: json['userAvatar'] ?? '',
        reaction: json['reaction'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'idReaction': idReaction,
        'entityType': entityType,
        'entityId': entityId,
        'idUser': idUser,
        'userName': userName,
        'userAvatar': userAvatar,
        'reaction': reaction,
        'createdAt': createdAt.toIso8601String(),
      };
}