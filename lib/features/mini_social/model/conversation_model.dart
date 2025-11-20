class ConversationModel {
  final String idConversation;
  final DateTime createdAt;
  final List<String> members;

  ConversationModel({
    required this.idConversation,
    required this.createdAt,
    required this.members,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      idConversation: json['idConversation'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      members: List<String>.from(json['members'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idConversation': idConversation,
      'createdAt': createdAt.toIso8601String(),
      'members': members,
    };
  }

  ConversationModel copyWith({
    String? idConversation,
    DateTime? createdAt,
    List<String>? members,
  }) {
    return ConversationModel(
      idConversation: idConversation ?? this.idConversation,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? List<String>.from(this.members),
    );
  }
}
