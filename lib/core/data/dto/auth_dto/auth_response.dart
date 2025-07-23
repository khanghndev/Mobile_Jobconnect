import '../../models/account_model.dart';

class AuthResponse {
  final String token;
  final Account user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: Account.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};

  @override
  String toString() => 'AuthResponse(token: \$token, user: \$user)';
}
