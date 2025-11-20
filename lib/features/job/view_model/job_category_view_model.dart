import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/job/model/job_category_model.dart';
import 'package:job_connect/features/mini_social/service/job_category_service.dart';

class JobCategoryViewModel extends ChangeNotifier {
  final JobCategoryService _jobCategoryService = JobCategoryService();

  // STATE
  bool _isLoading = false;
  String? _errorMessage;
  List<JobCategoryModel> _categories = [];
  JobCategoryModel? _selectedCategory;

  // GETTERS
  List<JobCategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JobCategoryModel? get selectedCategory => _selectedCategory;
  List<JobCategoryModel> get activeCategories =>
      _categories.where((c) => c.isActive == true).toList();

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    String? errorMessage,
    List<JobCategoryModel>? categories,
    JobCategoryModel? selectedCategory,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _errorMessage = errorMessage;
    _categories = categories ?? _categories;
    _selectedCategory = selectedCategory ?? _selectedCategory;
    notifyListeners();
  }

  // API HANDLER (generic)
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
    String? errorMsg,
  }) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isLoading: false);
    } on ServerException catch (e) {
      _setState(isLoading: false, errorMessage: e.err);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
    }
  }

  // PUBLIC API METHODS

  /// Tải tất cả category từ API và lưu vào state
  Future<void> fetchAllCategories() async {
    await _handleApiCall<List<JobCategoryModel>>(
      apiCall: () => _jobCategoryService.getAllCategories(),
      onSuccess: (list) {
        _setState(categories: list, errorMessage: null);
      },
      errorMsg: 'Lỗi khi tải danh sách danh mục',
    );
  }

  /// Lấy category theo id và đặt thành selectedCategory (không thay đổi list hiện tại)
  Future<void> fetchCategoryById(String id) async {
    await _handleApiCall<JobCategoryModel?>(
      apiCall: () => _jobCategoryService.getCategoryById(id),
      onSuccess: (cat) {
        if (cat != null) {
          _setState(selectedCategory: cat, errorMessage: null);
        } else {
          _setState(errorMessage: 'Không tìm thấy category với id $id');
        }
      },
      errorMsg: 'Lỗi khi tải danh mục theo ID',
    );
  }

  /// Lấy category theo code và đặt thành selectedCategory
  Future<void> fetchCategoryByCode(String code) async {
    await _handleApiCall<JobCategoryModel?>(
      apiCall: () => _jobCategoryService.getCategoryByCode(code),
      onSuccess: (cat) {
        if (cat != null) {
          _setState(selectedCategory: cat, errorMessage: null);
        } else {
          _setState(errorMessage: 'Không tìm thấy category với code $code');
        }
      },
      errorMsg: 'Lỗi khi tải danh mục theo code',
    );
  }

  /// Lấy danh sách category active (tải lại nếu chưa có)
  Future<void> ensureActiveCategoriesLoaded() async {
    if (_categories.isEmpty) {
      await fetchAllCategories();
    }
    // nothing else; activeCategories getter will compute.
  }

  // UTILS
  void clearError() {
    _setState(errorMessage: null);
  }

  void clearSelected() {
    _setState(selectedCategory: null);
  }
}