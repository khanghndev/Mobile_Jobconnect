import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyService _companyService = CompanyService();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isFeaturedLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;

  List<CompanyModel> _companies = [];
  List<CompanyModel> _filteredCompanies = [];
  List<CompanyModel> _featuredCompanies = [];
  CompanyModel? _companyDetail;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isFeaturedLoading => _isFeaturedLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  List<CompanyModel> get companies => _companies;
  List<CompanyModel> get filteredCompanies => _filteredCompanies;
  List<CompanyModel> get featuredCompanies => _featuredCompanies;
  CompanyModel? get companyDetail => _companyDetail;

  //TODO: Cập nhật state nội bộ
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? isFeaturedLoading,
    bool? isDetailLoading,
    String? errorMessage,
    List<CompanyModel>? companies,
    List<CompanyModel>? filteredCompanies,
    List<CompanyModel>? featuredCompanies,
    CompanyModel? companyDetail,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _isFeaturedLoading = isFeaturedLoading ?? _isFeaturedLoading;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;
    _errorMessage = errorMessage;
    _companies = companies ?? _companies;
    _filteredCompanies = filteredCompanies ?? _filteredCompanies;
    _featuredCompanies = featuredCompanies ?? _featuredCompanies;
    _companyDetail = companyDetail ?? _companyDetail;
    notifyListeners();
  }

  //TODO: Gọi API danh sách công ty
  Future<void> getCompanies() async {
    await _handleApiCall(
      apiCall: () => _companyService.getCompanies(),
      onSuccess: (data) {
        data.sort((a, b) =>
            a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase()));
        _setState(
          companies: data,
          filteredCompanies: data,
          isSuccess: true,
        );
      },
    );
  }

  //TODO: Gọi API công ty nổi bật
  Future<void> getFeaturedCompanies() async {
    await _handleApiCall(
      apiCall: () => _companyService.getFeaturedCompanies(),
      onSuccess: (data) {
        _setState(featuredCompanies: data);
      },
      isFeatured: true,
    );
  }

  // TODO: Gọi API chi tiết công ty theo ID
  Future<void> getCompanyDetail(String id) async {
    _setState(isDetailLoading: true, errorMessage: null);

    try {
      final detail = await _companyService.getCompanyById(id:id);
      _setState(companyDetail: detail, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isDetailLoading: false);
    }
  }

  //TODO: Hàm xử lý API chung (giảm lặp code)
  Future<void> _handleApiCall({
    required Future<List<CompanyModel>> Function() apiCall,
    required void Function(List<CompanyModel>) onSuccess,
    bool isFeatured = false,
  }) async {
    if (isFeatured) {
      _setState(isFeaturedLoading: true, errorMessage: null);
    } else {
      _setState(isLoading: true, errorMessage: null, isSuccess: false);
    }

    try {
      final data = await apiCall();
      onSuccess(data);
    } on ServerException catch (e) {
      _setState(
        errorMessage: e.toString(),
        isSuccess: false,
      );
    } catch (e) {
      _setState(
        errorMessage: e.toString(),
        isSuccess: false,
      );
    } finally {
      if (isFeatured) {
        _setState(isFeaturedLoading: false);
      } else {
        _setState(isLoading: false);
      }
    }
  }

  //TODO: Lọc danh sách công ty
  void filterCompanies(String keyword) {
    if (keyword.isEmpty) {
      _setState(filteredCompanies: _companies);
      return;
    }

    final lower = keyword.toLowerCase();
    final filtered = _companies.where((company) {
      final name = company.companyName.toLowerCase();
      final industry = company.industry.toLowerCase();
      return name.contains(lower) || industry.contains(lower);
    }).toList();

    _setState(filteredCompanies: filtered);
  }

  //TODO: Làm mới danh sách công ty
  Future<void> refreshCompanies() async => await getCompanies();

  //TODO: Reset toàn bộ state
  void reset() {
    _setState(
      isLoading: false,
      isFeaturedLoading: false,
      isDetailLoading: false,
      isSuccess: false,
      errorMessage: null,
      companies: [],
      filteredCompanies: [],
      featuredCompanies: [],
      companyDetail: null,
    );
  }
}
