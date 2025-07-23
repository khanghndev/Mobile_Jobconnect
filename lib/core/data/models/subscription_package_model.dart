class SubscriptionPackage {
  final String idPackage;
  final String packageName;
  final double price;
  final int durationDays;
  final String? description;
  final int jobPostLimit;
  final int cvViewLimit;
  final DateTime createdAt;
  final bool isActive;

  SubscriptionPackage({
    required this.idPackage,
    required this.packageName,
    required this.price,
    required this.durationDays,
    this.description,
    required this.jobPostLimit,
    required this.cvViewLimit,
    required this.createdAt,
    required this.isActive,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      idPackage: json['idPackage'] as String,
      packageName: json['packageName'] as String,
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] as int,
      description: json['description'] as String?,
      jobPostLimit: json['jobPostLimit'] as int,
      cvViewLimit: json['cvViewLimit'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'idPackage': idPackage,
    'packageName': packageName,
    'price': price,
    'durationDays': durationDays,
    'description': description,
    'jobPostLimit': jobPostLimit,
    'cvViewLimit': cvViewLimit,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };
}
