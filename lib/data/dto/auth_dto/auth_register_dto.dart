class RegisterDto {
  final String userName;
  final String email;
  final String password;
  final String phoneNumber;
  final String roleName;

  RegisterDto({
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.roleName,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'roleName': roleName,
  };
}
