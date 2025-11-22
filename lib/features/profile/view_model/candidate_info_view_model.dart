import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';

class CandidateInfoViewModel extends ChangeNotifier {
  final CandidateInfoService _candidateService = CandidateInfoService();

  bool _isLoading = false;
  bool _isDetailLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<CandidateInfoModel> _candidates = [];
  CandidateInfoModel? _candidateDetail;

  //TODO: Getters
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  List<CandidateInfoModel> get candidates => _candidates;
  CandidateInfoModel? get candidateDetail => _candidateDetail;

  //TODO: Private: cập nhật state và notify
  void _setState({
    bool? isLoading,
    bool? isDetailLoading,
    bool? isSuccess,
    String? errorMessage,
    List<CandidateInfoModel>? candidates,
    CandidateInfoModel? candidateDetail,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _candidates = candidates ?? _candidates;
    _candidateDetail = candidateDetail ?? _candidateDetail;
    notifyListeners();
  }

  //TODO: Lấy chi tiết ứng viên theo ID
  Future<CandidateInfoModel?> getCandidateDetail(String id) async {
    _setState(isDetailLoading: true, errorMessage: null);
    try {
      final detail = await _candidateService.getCandidateById(id: id);
      _setState(candidateDetail: detail, isSuccess: true);
      return detail;
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isDetailLoading: false);
    }
    return null;
  }

  //TODO: Tạo ứng viên mới
  Future<void> createCandidate(CandidateInfoModel candidate) async {
    await _handleApiCall(
      apiCall: () async => [await _candidateService.createCandidate(candidate)],
      onSuccess: (data) {
        _setState(candidates: [..._candidates, ...data], isSuccess: true);
      },
    );
  }

  //TODO: Cập nhật ứng viên
  Future<void> updateCandidate(String id, CandidateInfoModel candidate) async {
    await _handleApiCall(
      apiCall: () async => [await _candidateService.updateCandidate(id: id, candidate: candidate)],
      onSuccess: (data) {
        final updatedCandidate = data.first;
        final index = _candidates.indexWhere((c) => c.idUser == id);
        if (index >= 0) {
          _candidates[index] = updatedCandidate;
        }
        _setState(candidates: _candidates, isSuccess: true);
      },
    );
  }

  //TODO: Xóa ứng viên
  Future<void> deleteCandidate(String id) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      await _candidateService.deleteCandidate(id: id);
      _candidates.removeWhere((c) => c.idUser == id);
      _setState(candidates: _candidates, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    }  
  }

  //TODO: Hàm xử lý API chung
  Future<void> _handleApiCall({
    required Future<List<CandidateInfoModel>> Function() apiCall,
    required void Function(List<CandidateInfoModel>) onSuccess,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      final data = await apiCall();
      onSuccess(data);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    }  
  }

  //TODO: Làm mới chi tiết ứng viên
  Future<void> refreshCandidate() async {
    if (_candidateDetail != null) {
      await getCandidateDetail(_candidateDetail!.idUser!);
    }
  }

  //TODO: Reset toàn bộ state
  void reset() {
    _setState(
      isLoading: false,
      isDetailLoading: false,
      isSuccess: false,
      errorMessage: null,
      candidates: [],
      candidateDetail: null,
    );
  }
}
