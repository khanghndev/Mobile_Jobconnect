import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/company/model/company_model.dart';

class CompanyService {
  final ApiService _apiService;

  CompanyService() : _apiService = ApiService();

  //TODO: HÀM DÙNG CHUNG XỬ LÝ DANH SÁCH
  Future<List<CompanyModel>> _fetchCompanyList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res is! List) {
        throw ServerException(
          err:
              'Phản hồi không hợp lệ từ API ($dataType): không phải danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: LẤY DANH SÁCH CÔNG TY
  Future<List<CompanyModel>> getCompanies() async {
    return _fetchCompanyList(
      endpoint: ApiConstants.companiesEndpoint,
      dataType: 'danh sách công ty',
    );
  }

  //TODO: LẤY DANH SÁCH CÔNG TY NỔI BẬT
  Future<List<CompanyModel>> getFeaturedCompanies() async {
    return _fetchCompanyList(
      endpoint: ApiConstants.companiesFeaturedEndpoint,
      dataType: 'công ty nổi bật',
    );
  }

  //TODO: LẤY CHI TIẾT CÔNG TY THEO ID
  Future<CompanyModel> getCompanyById({required String id}) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.companiesEndpoint}/$id',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết công ty)',
          type: ServerExceptionType.api,
        );
      }

      return CompanyModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err:
            'Lỗi không xác định khi tải chi tiết công ty: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: TẠO CÔNG TY MỚI
  Future<CompanyModel> createCompany(CompanyModel company) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.companiesEndpoint,
        body: company.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo công ty)',
          type: ServerExceptionType.api,
        );
      }

      return CompanyModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo công ty mới: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: CẬP NHẬT THÔNG TIN CÔNG TY
  Future<CompanyModel> updateCompany({required CompanyModel company,}) async {
    try {
      final body = {
        'companyName': company.companyName,
        'taxCode': company.taxCode,
        'address': company.address,
        'description': company.description,
        'logoCompany': company.logoCompany,
        'websiteUrl': company.websiteUrl,
        'scale': company.scale,
        'industry': company.industry,
        'businessLicenseUrl': company.businessLicenseUrl,
        'status': company.status,
        'isFeatured': company.isFeatured,
      }..removeWhere((key, value) => value == null);

      final res = await _apiService.put(
        endpoint: '${ApiConstants.companiesEndpoint}/${company.idCompany}',
        body: body,
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật công ty)',
          type: ServerExceptionType.api,
        );
      }

      return CompanyModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật công ty: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: XÓA CÔNG TY THEO ID
  Future<void> deleteCompany({required String id}) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.companiesEndpoint}/$id',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa công ty: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}