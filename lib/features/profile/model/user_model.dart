import 'package:job_connect/data/models/role_model.dart';

class UserModel {
  final String idUser;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String idRole;
  final String accountStatus;
  final String? avatarUrl;
  final String? socialLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String gender;
  final String? address;
  final DateTime? dateOfBirth;
  final RoleModel? role;

  UserModel({
    required this.idUser,
    required this.userName,
    required this.email,
    this.phoneNumber,
    this.password,
    required this.idRole,
    required this.accountStatus,
    this.avatarUrl,
    this.socialLogin,
    required this.createdAt,
    required this.updatedAt,
    required this.gender,
    this.address,
    this.dateOfBirth,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['idUser'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      password: json['password'] as String?,
      idRole: json['idRole'] as String,
      accountStatus: json['accountStatus'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      socialLogin: json['socialLogin'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gender: json['gender'] as String,
      address: json['address'] as String?,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      role: json['role'] != null ? RoleModel.fromJson(json['role'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'idUser': idUser,
      'userName': userName,
      'email': email,
      'idRole': idRole,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gender': gender,
    };
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (password != null) data['password'] = password;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (socialLogin != null) data['socialLogin'] = socialLogin;
    if (address != null) data['address'] = address;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (role != null) data['role'] = role!.toJson();
    return data;
  }

  UserModel copyWith({
    String? idUser,
    String? userName,
    String? email,
    String? phoneNumber,
    String? password,
    String? idRole,
    String? accountStatus,
    String? avatarUrl,
    String? socialLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
    String? address,
    DateTime? dateOfBirth,
    RoleModel? role,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      idRole: idRole ?? this.idRole,
      accountStatus: accountStatus ?? this.accountStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      socialLogin: socialLogin ?? this.socialLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
    );
  }
  
  @override
  String toString() {
    return 'UserModel(idUser: $idUser, userName: $userName, email: $email, idRole: $idRole, gender: $gender, accountStatus: $accountStatus, role: ${role?.roleName})';
  }
}
