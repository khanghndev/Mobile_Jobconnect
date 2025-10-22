class MessageModel {
  final String idMessage;
  final String threadId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.idMessage,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        idMessage: json['idMessage'],
        threadId: json['idThread'],
        senderId: json['idSender'],
        content: json['content'],
        sentAt: DateTime.parse(json['sentAt']).toLocal(),
        isRead: json['isRead'],
      );

  Map<String, dynamic> toJson() => {
        'idMessage': idMessage,
        'idThread': threadId,
        'idSender': senderId,
        'content': content,
        'sentAt': sentAt.toUtc().toIso8601String(),
        'isRead': isRead,
      };

  MessageModel copyWith({
    String? idMessage,
    String? threadId,
    String? senderId,
    String? content,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return MessageModel(
      idMessage: idMessage ?? this.idMessage,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() => 'MessageModel($idMessage - $senderId)';
}