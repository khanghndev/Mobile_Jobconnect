class FriendModel {
  final String id;
  final String name;
  final String avatar;
  final String email;
  final DateTime createdAt;
  final DateTime lastActivity;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.email,
    required this.createdAt,
    required this.lastActivity,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastActivity:
          DateTime.tryParse(json['lastActivity'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}