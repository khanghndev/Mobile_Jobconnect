import '../../../data/models/account_model.dart';

class LoginModel {
  final String token;
  final Account user;
  final bool needProfile;

  LoginModel({
    required this.token,
    required this.user,
    required this.needProfile,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'] as String,
      user: Account.fromJson(json['user'] as Map<String, dynamic>),
      needProfile: json['needProfile'] as bool? ?? false, // default false
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
        'needProfile': needProfile,
      };

  @override
  String toString() =>
      'LoginModel(token: $token, user: $user, needProfile: $needProfile)';
}
