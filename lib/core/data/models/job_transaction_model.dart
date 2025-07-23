class JobTransaction {
  final String idTransaction;
  final String idUser;
  final String idPackage;
  final double amount;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String? status;

  JobTransaction({
    required this.idTransaction,
    required this.idUser,
    required this.idPackage,
    required this.amount,
    this.paymentMethod,
    required this.transactionDate,
    this.status,
  });

  factory JobTransaction.fromJson(Map<String, dynamic> json) {
    return JobTransaction(
      idTransaction: json['idTransaction'] as String,
      idUser: json['idUser'] as String,
      idPackage: json['idPackage'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'idTransaction': idTransaction,
    'idUser': idUser,
    'idPackage': idPackage,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'transactionDate': transactionDate.toIso8601String(),
    'status': status,
  };
}
