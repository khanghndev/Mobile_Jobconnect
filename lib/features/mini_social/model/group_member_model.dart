class GroupMemberModel {
  final String idUser;
  final String userName;
  final String email;
  final String avatarUrl;
  final String roleInGroup;
  final String status;
  final DateTime joinedAt;

  GroupMemberModel({
    required this.idUser,
    required this.userName,
    required this.email,
    required this.avatarUrl,
    required this.roleInGroup,
    required this.status,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => GroupMemberModel(
        idUser: json['idUser'] ?? '',
        userName: json['userName'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        roleInGroup: json['roleInGroup'] ?? '',
        status: json['status'] ?? '',
        joinedAt: DateTime.parse(json['joinedAt']),
      );

  Map<String, dynamic> toJson() => {
        'idUser': idUser,
        'userName': userName,
        'email': email,
        'avatarUrl': avatarUrl,
        'roleInGroup': roleInGroup,
        'status': status,
        'joinedAt': joinedAt.toIso8601String(),
      };

  GroupMemberModel copyWith({
    String? idUser,
    String? userName,
    String? email,
    String? avatarUrl,
    String? roleInGroup,
    String? status,
    DateTime? joinedAt,
  }) {
    return GroupMemberModel(
      idUser: idUser ?? this.idUser,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleInGroup: roleInGroup ?? this.roleInGroup,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  String toString() => 'GroupMemberModel($userName [$idUser], role: $roleInGroup, status: $status)';
}
