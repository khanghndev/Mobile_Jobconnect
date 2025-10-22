class RoleModel {
  final String idRole;
  final String roleName;
  final String? description;

  RoleModel({
    required this.idRole,
    required this.roleName,
    this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        idRole: json['idRole'] as String,
        roleName: json['roleName'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'idRole': idRole,
        'roleName': roleName,
        'description': description,
      };

  RoleModel copyWith({
    String? idRole,
    String? roleName,
    String? description,
  }) {
    return RoleModel(
      idRole: idRole ?? this.idRole,
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'RoleModel($idRole - $roleName)';
}
