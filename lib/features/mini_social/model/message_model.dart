class MessageModel {
  final String idMessage;
  final String idConversation;
  final String idSender;
  final String content;
  final String messageType;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.idMessage,
    required this.idConversation,
    required this.idSender,
    required this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      idMessage: json['id'] ?? '',
      idConversation: json['idConversation'] ?? '',
      idSender: json['idSender'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? '',
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'] is int ? json['fileSize'] : int.tryParse('${json['fileSize']}'),
      sentAt: DateTime.parse(json['sentAt']),
      isRead: (json['isRead'] ?? 0) == 1,
    );
  }

  /// NEW: fromMap (dùng cho SignalR realtime messages)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      idMessage: map['idMessage'] ?? map['id'] ?? '',
      idConversation: map['idConversation'] ?? '',
      idSender: map['idSender'] ?? '',
      content: map['content'] ?? '',
      messageType: map['messageType'] ?? 'text',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileSize: map['fileSize'] is int ? map['fileSize'] : int.tryParse('${map['fileSize']}'),
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] == 1 || map['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMessage': idMessage,
      'idConversation': idConversation,
      'idSender': idSender,
      'content': content,
      'messageType': messageType,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  MessageModel copyWith({
    String? idMessage,
    String? idConversation,
    String? idSender,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return MessageModel(
      idMessage: idMessage ?? this.idMessage,
      idConversation: idConversation ?? this.idConversation,
      idSender: idSender ?? this.idSender,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
