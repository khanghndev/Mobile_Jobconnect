class CompanyModel {
  final String idCompany;
  final String companyName;
  final String? taxCode;
  final String address;
  final String? description;
  final String? logoCompany;
  final String? websiteUrl;
  final String scale;
  final String industry;
  final String? businessLicenseUrl;
  final String status;
  final int isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? employerType;
  final String? idUser;
  final String? idNumber;
  final int isVerified;

  CompanyModel({
    required this.idCompany,
    required this.companyName,
    this.taxCode,
    required this.address,
    this.description,
    this.logoCompany,
    this.websiteUrl,
    required this.scale,
    required this.industry,
    this.businessLicenseUrl,
    required this.status,
    required this.isFeatured,
    this.createdAt,
    this.updatedAt,
    this.employerType = 'company',
    this.idUser,
    this.idNumber,
    this.isVerified = 0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }

    return CompanyModel(
      idCompany: json['idCompany']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      taxCode: json['taxCode']?.toString(),
      address: json['address']?.toString() ?? '',
      description: json['description']?.toString(),
      logoCompany: json['logoCompany']?.toString(),
      websiteUrl: json['websiteUrl']?.toString(),
      scale: json['scale']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      businessLicenseUrl: json['businessLicenseUrl']?.toString(),
      status: json['status']?.toString() ?? '',
      isFeatured: (json['isFeatured'] is int)
          ? json['isFeatured'] as int
          : int.tryParse(json['isFeatured']?.toString() ?? '0') ?? 0,
      createdAt: parseDateTime(json['createdAt']?.toString()),
      updatedAt: parseDateTime(json['updatedAt']?.toString()),
      employerType: json['employerType']?.toString() ?? 'company',
      idUser: json['idUser']?.toString(),
      idNumber: json['idNumber']?.toString(),
      isVerified: (json['isVerified'] is int)
          ? json['isVerified'] as int
          : int.tryParse(json['isVerified']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCompany': idCompany,
      'companyName': companyName,
      'taxCode': taxCode,
      'address': address,
      'description': description,
      'logoCompany': logoCompany,
      'websiteUrl': websiteUrl,
      'scale': scale,
      'industry': industry,
      'businessLicenseUrl': businessLicenseUrl,
      'status': status,
      'isFeatured': isFeatured,
      'employerType': employerType,
      'idUser': idUser,
      'idNumber': idNumber,
      'isVerified': isVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Company('
      'idCompany: $idCompany, '
      'companyName: $companyName, '
      'taxCode: $taxCode, '
      'address: $address, '
      'scale: $scale, '
      'industry: $industry, '
      'status: $status, '
      'isFeatured: $isFeatured, '
      'employerType: $employerType, '
      'idUser: $idUser, '
      'idNumber: $idNumber, '
      'isVerified: $isVerified, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
    ')';
  }
}
