class JobTransactionModel {
  final String idTransaction;
  final String idUser;
  final String idPackage;
  final double amount;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String? status;

  JobTransactionModel({
    required this.idTransaction,
    required this.idUser,
    required this.idPackage,
    required this.amount,
    this.paymentMethod,
    required this.transactionDate,
    this.status,
  });

  factory JobTransactionModel.fromJson(Map<String, dynamic> json) =>
      JobTransactionModel(
        idTransaction: json['idTransaction'],
        idUser: json['idUser'],
        idPackage: json['idPackage'],
        amount: (json['amount'] as num).toDouble(),
        paymentMethod: json['paymentMethod'],
        transactionDate: DateTime.parse(json['transactionDate']),
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'idTransaction': idTransaction,
        'idUser': idUser,
        'idPackage': idPackage,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionDate': transactionDate.toIso8601String(),
        'status': status,
      };

  JobTransactionModel copyWith({
    String? idTransaction,
    String? idUser,
    String? idPackage,
    double? amount,
    String? paymentMethod,
    DateTime? transactionDate,
    String? status,
  }) {
    return JobTransactionModel(
      idTransaction: idTransaction ?? this.idTransaction,
      idUser: idUser ?? this.idUser,
      idPackage: idPackage ?? this.idPackage,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'JobTransactionModel($idTransaction - $amount)';
}
