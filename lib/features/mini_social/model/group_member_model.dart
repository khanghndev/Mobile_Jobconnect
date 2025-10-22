class GroupMemberModel {
  final String idGroup;
  final String idUser;
  final String role;
  final DateTime joinedAt;

  GroupMemberModel({
    required this.idGroup,
    required this.idUser,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => GroupMemberModel(
        idGroup: json['idGroup'],
        idUser: json['idUser'],
        role: json['role'],
        joinedAt: DateTime.parse(json['joinedAt']),
      );

  Map<String, dynamic> toJson() => {
        'idGroup': idGroup,
        'idUser': idUser,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
      };

  GroupMemberModel copyWith({
    String? idGroup,
    String? idUser,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupMemberModel(
      idGroup: idGroup ?? this.idGroup,
      idUser: idUser ?? this.idUser,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  String toString() => 'GroupMemberModel($idUser in $idGroup)';
}
