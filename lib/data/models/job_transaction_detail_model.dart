class JobTransactionDetailModel {
  final String idTransaction;
  final String? amountFormatted;
  final String? amountInWords;
  final String? senderName;
  final String? senderBank;
  final String? receiverName;
  final String? receiverBank;
  final String? content;
  final String? fee;

  JobTransactionDetailModel({
    required this.idTransaction,
    this.amountFormatted,
    this.amountInWords,
    this.senderName,
    this.senderBank,
    this.receiverName,
    this.receiverBank,
    this.content,
    this.fee,
  });

  factory JobTransactionDetailModel.fromJson(Map<String, dynamic> json) =>
      JobTransactionDetailModel(
        idTransaction: json['idTransaction'],
        amountFormatted: json['amountFormatted'],
        amountInWords: json['amountInWords'],
        senderName: json['senderName'],
        senderBank: json['senderBank'],
        receiverName: json['receiverName'],
        receiverBank: json['receiverBank'],
        content: json['content'],
        fee: json['fee'],
      );

  Map<String, dynamic> toJson() => {
        'idTransaction': idTransaction,
        'amountFormatted': amountFormatted,
        'amountInWords': amountInWords,
        'senderName': senderName,
        'senderBank': senderBank,
        'receiverName': receiverName,
        'receiverBank': receiverBank,
        'content': content,
        'fee': fee,
      };

  JobTransactionDetailModel copyWith({
    String? idTransaction,
    String? amountFormatted,
    String? amountInWords,
    String? senderName,
    String? senderBank,
    String? receiverName,
    String? receiverBank,
    String? content,
    String? fee,
  }) {
    return JobTransactionDetailModel(
      idTransaction: idTransaction ?? this.idTransaction,
      amountFormatted: amountFormatted ?? this.amountFormatted,
      amountInWords: amountInWords ?? this.amountInWords,
      senderName: senderName ?? this.senderName,
      senderBank: senderBank ?? this.senderBank,
      receiverName: receiverName ?? this.receiverName,
      receiverBank: receiverBank ?? this.receiverBank,
      content: content ?? this.content,
      fee: fee ?? this.fee,
    );
  }

  @override
  String toString() => 'JobTransactionDetailModel($idTransaction)';
}