// resume_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/resume/service/resum_service.dart';

class ResumeViewModel extends ChangeNotifier {
  final ResumeService _resumeService = ResumeService();
  final StorageAppwriteService _storageService = StorageAppwriteService();

  final String _bucketId = dotenv.env['APPWRITE_BUCKET_ID_RESUME'] ?? '';

  // Trạng thái
  bool _isListLoading = false;      // Loading khi lấy danh sách
  bool _isActionLoading = false;    // Loading khi tạo/update/delete
  bool _isDetailLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<ResumeModel> _resumes = [];
  List<ResumeModel> _filteredResumes = [];
  ResumeModel? _defaultResume;
  ResumeModel? _lastCreatedResume;

  // Getters
  bool get isListLoading => _isListLoading;
  bool get isActionLoading => _isActionLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<ResumeModel> get resumes => _resumes;
  List<ResumeModel> get filteredResumes => _filteredResumes;
  ResumeModel? get defaultResume => _defaultResume;
  ResumeModel? get lastCreatedResume => _lastCreatedResume;

  // Internal state setter
  void _setState({
    bool? isListLoading,
    bool? isActionLoading,
    bool? isDetailLoading,
    bool? isSuccess,
    String? errorMessage,
    List<ResumeModel>? resumes,
    List<ResumeModel>? filteredResumes,
    ResumeModel? defaultResume,
  }) {
    _isListLoading = isListLoading ?? _isListLoading;
    _isActionLoading = isActionLoading ?? _isActionLoading;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _resumes = resumes ?? _resumes;
    _filteredResumes = filteredResumes ?? _filteredResumes;
    _defaultResume = defaultResume ?? _defaultResume;
    notifyListeners();
  }

  // Helper generic function
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    bool isList = false, // dùng để set đúng loading type
    void Function(T)? onSuccess,
  }) async {
    _setState(
      isListLoading: isList ? true : null,
      isActionLoading: isList ? null : true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(
        isListLoading: isList ? false : null,
        isActionLoading: isList ? null : false,
        isSuccess: true,
      );
    } on ServerException catch (e) {
      _setState(
        isListLoading: isList ? false : null,
        isActionLoading: isList ? null : false,
        errorMessage: e.err,
        isSuccess: false,
      );
    } catch (e) {
      _setState(
        isListLoading: isList ? false : null,
        isActionLoading: isList ? null : false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  // GET ALL RESUMES
  Future<void> getAllResumes() async {
    await _handleApiCall<List<ResumeModel>>(
      isList: true,
      apiCall: () => _resumeService.getAllResumes(),
      onSuccess: (data) => _setState(resumes: data, filteredResumes: data),
    );
  }

  // GET RESUMES BY USER
  Future<void> getResumesByUser({required String idUser}) async {
    await _handleApiCall<List<ResumeModel>>(
      isList: true,
      apiCall: () => _resumeService.getResumesByUser(idUser: idUser),
      onSuccess: (data) => _setState(resumes: data, filteredResumes: data),
    );
  }

  // GET DEFAULT RESUME
  Future<void> getDefaultResume({required String candidateId}) async {
    _setState(isDetailLoading: true);
    try {
      final data = await _resumeService.getDefaultResume(candidateId: candidateId);
      _setState(defaultResume: data);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err);
    } finally {
      _setState(isDetailLoading: false);
    }
  }

  // CREATE RESUME
  Future<void> createResume({required ResumeModel resume, required File file}) async {
    await _handleApiCall<ResumeModel>(
      apiCall: () async {
        final aw.File uploaded = await _storageService.uploadFile(file, bucketId: _bucketId);
        final fileUrl = _storageService.getFileViewUrl(uploaded.$id, bucketId: _bucketId);
        final resumeWithFile = resume.copyWith(fileId: uploaded.$id, fileUrl: fileUrl);
        final newResume = await _resumeService.createResume(resumeWithFile);
        _lastCreatedResume = newResume;
        final updatedList = [..._resumes, newResume];
        _setState(resumes: updatedList, filteredResumes: updatedList);
        return newResume;
      },
    );
  }

  // UPDATE RESUME
  Future<void> updateResume({required String id, required ResumeModel updated, File? newFile}) async {
    await _handleApiCall<void>(
      apiCall: () async {
        ResumeModel finalResume = updated;
        if (newFile != null) {
          if (updated.fileId.isNotEmpty) {
            await _storageService.deleteFile(updated.fileId, bucketId: _bucketId);
          }
          final aw.File uploaded = await _storageService.uploadFile(newFile, bucketId: _bucketId);
          final fileUrl = _storageService.getFileViewUrl(uploaded.$id, bucketId: _bucketId);
          finalResume = updated.copyWith(fileId: uploaded.$id, fileUrl: fileUrl);
        }
        await _resumeService.updateResume(id: id, updated: finalResume);
        await getResumesByUser(idUser: finalResume.idUser);
      },
    );
  }

  // DELETE RESUME
  Future<void> deleteResume({required String idResume, required String fileId, required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () async {
        if (fileId.isNotEmpty) {
          await _storageService.deleteFile(fileId, bucketId: _bucketId);
        }
        await _resumeService.deleteResume(idResume: idResume);
        await getResumesByUser(idUser: userId);
      },
    );
  }

  // SET DEFAULT RESUME
  Future<void> setDefaultResume({required String userId, required String fileId}) async {
    await _handleApiCall<void>(
      apiCall: () async {
        await _resumeService.setDefaultResume(userId: userId, fileId: fileId);
        await getResumesByUser(idUser: userId);
      },
    );
  }

  // SEARCH RESUME
  void searchResumes({required String keyword}) {
    _filteredResumes = keyword.isEmpty
        ? _resumes
        : _resumes.where((r) => r.fileName.toLowerCase().contains(keyword.toLowerCase())).toList();
    notifyListeners();
  }

  // RESET
  void reset() {
    _setState(
      isListLoading: false,
      isActionLoading: false,
      isDetailLoading: false,
      isSuccess: false,
      errorMessage: null,
      resumes: [],
      filteredResumes: [],
      defaultResume: null,
    );
  }
}