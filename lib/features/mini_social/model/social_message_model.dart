class SocialMessageModel {
  final String idMessage;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  SocialMessageModel({
    required this.idMessage,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    required this.sentAt,
  });

  factory SocialMessageModel.fromJson(Map<String, dynamic> json) =>
      SocialMessageModel(
        idMessage: json['idMessage'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        content: json['content'],
        isRead: json['isRead'] == 1 || json['isRead'] == true,
        sentAt: DateTime.parse(json['sentAt']),
      );

  Map<String, dynamic> toJson() => {
        'idMessage': idMessage,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'isRead': isRead ? 1 : 0,
        'sentAt': sentAt.toIso8601String(),
      };

  SocialMessageModel copyWith({
    String? idMessage,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isRead,
    DateTime? sentAt,
  }) {
    return SocialMessageModel(
      idMessage: idMessage ?? this.idMessage,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  String toString() =>
      'SocialMessageModel(from: $senderId, to: $receiverId, content: $content)';
}
