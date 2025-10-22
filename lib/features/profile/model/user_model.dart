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
      role: RoleModel.fromJson(json['role'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'idRole': idRole,
      'accountStatus': accountStatus,
      'avatarUrl': avatarUrl,
      'socialLogin': socialLogin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gender': gender,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'role': role?.toJson(),
    };
  }

  @override
  String toString() {
    return 'UserModel(idUser: $idUser, userName: $userName, email: $email, idRole: $idRole, gender: $gender, accountStatus: $accountStatus, role: ${role?.roleName})';
  }
}
