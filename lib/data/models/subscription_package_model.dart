class SubscriptionPackageModel {
  final String idPackage;
  final String packageName;
  final double price;
  final int durationDays;
  final String? description;
  final int jobPostLimit;
  final int cvViewLimit;
  final DateTime createdAt;
  final bool isActive;

  SubscriptionPackageModel({
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

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionPackageModel(
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

  SubscriptionPackageModel copyWith({
    String? idPackage,
    String? packageName,
    double? price,
    int? durationDays,
    String? description,
    int? jobPostLimit,
    int? cvViewLimit,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return SubscriptionPackageModel(
      idPackage: idPackage ?? this.idPackage,
      packageName: packageName ?? this.packageName,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      description: description ?? this.description,
      jobPostLimit: jobPostLimit ?? this.jobPostLimit,
      cvViewLimit: cvViewLimit ?? this.cvViewLimit,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'SubscriptionPackageModel(idPackage: $idPackage, packageName: $packageName, price: $price, durationDays: $durationDays, '
      'description: $description, jobPostLimit: $jobPostLimit, cvViewLimit: $cvViewLimit, '
      'createdAt: $createdAt, isActive: $isActive)';
}
