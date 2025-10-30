import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/resume/service/resum_service.dart';

class ResumeViewModel extends ChangeNotifier {
  final ResumeService _resumeService = ResumeService();
  final StorageAppwriteService _storageService = StorageAppwriteService();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isDetailLoading = false;
  String? _errorMessage;

  List<ResumeModel> _resumes = [];
  List<ResumeModel> _filteredResumes = [];
  ResumeModel? _defaultResume;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  List<ResumeModel> get resumes => _resumes;
  List<ResumeModel> get filteredResumes => _filteredResumes;
  ResumeModel? get defaultResume => _defaultResume;

  // Internal state setter
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? isDetailLoading,
    String? errorMessage,
    List<ResumeModel>? resumes,
    List<ResumeModel>? filteredResumes,
    ResumeModel? defaultResume,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;
    _errorMessage = errorMessage;
    _resumes = resumes ?? _resumes;
    _filteredResumes = filteredResumes ?? _filteredResumes;
    _defaultResume = defaultResume ?? _defaultResume;
    notifyListeners();
  }

  // TODO: Lấy tất cả CV
  Future<void> getAllResumes() async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final data = await _resumeService.getAllResumes();
      _setState(resumes: data, filteredResumes: data, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Lấy danh sách CV theo userId
  Future<void> getResumesByUser({required String idUser}) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final data = await _resumeService.getResumesByUser(idUser: idUser);
      _setState(resumes: data, filteredResumes: data, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Lấy CV mặc định (CV hiển thị)
  Future<void> getDefaultResume({required String candidateId}) async {
    _setState(isDetailLoading: true);
    try {
      final data =
          await _resumeService.getDefaultResume(candidateId: candidateId);
      _setState(defaultResume: data);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err);
    } finally {
      _setState(isDetailLoading: false);
    }
  }

  // TODO: Tạo mới CV (upload file lên Appwrite trước)
  Future<void> createResume({
    required ResumeModel resume,
    required File file,
  }) async {
    _setState(isLoading: true);
    try {
      final aw.File uploaded = await _storageService.uploadFile(file);
      final fileUrl = _storageService.getFileViewUrl(uploaded.$id);

      final resumeWithFile = resume.copyWith(
        fileId: uploaded.$id,
        fileUrl: fileUrl,
      );

      final newResume = await _resumeService.createResume(resumeWithFile);

      final updatedList = [..._resumes, newResume];
      _setState(
        resumes: updatedList,
        filteredResumes: updatedList,
        isSuccess: true,
      );
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Cập nhật CV (nếu đổi file → upload mới & xóa file cũ)
  Future<void> updateResume({
    required String id,
    required ResumeModel updated,
    File? newFile,
  }) async {
    _setState(isLoading: true);
    try {
      ResumeModel finalResume = updated;

      if (newFile != null) {
        if (updated.fileId.isNotEmpty) {
          await _storageService.deleteFile(updated.fileId);
        }

        final aw.File uploaded = await _storageService.uploadFile(newFile);
        final fileUrl = _storageService.getFileViewUrl(uploaded.$id);

        finalResume = updated.copyWith(
          fileId: uploaded.$id,
          fileUrl: fileUrl,
        );
      }

      await _resumeService.updateResume(id: id, updated: finalResume);
      await getResumesByUser(idUser: finalResume.idUser);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Xóa CV (và file trên Appwrite)
  Future<void> deleteResume({
    required String idResume,
    required String fileId,
    required String userId,
  }) async {
    print('🧩 Delete Resume → fileId: $fileId');
    _setState(isLoading: true);
    try {
      if (fileId.isNotEmpty) {
        await _storageService.deleteFile(fileId);
      }

      await _resumeService.deleteResume(idResume: idResume);
      await getResumesByUser(idUser: userId);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Đặt CV mặc định
  Future<void> setDefaultResume({
    required String userId,
    required String fileId,
  }) async {
    _setState(isLoading: true);
    try {
      await _resumeService.setDefaultResume(userId: userId, fileId: fileId);
      await getResumesByUser(idUser: userId);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Tìm kiếm CV
  void searchResumes({required String keyword}) {
    if (keyword.isEmpty) {
      _filteredResumes = _resumes;
    } else {
      _filteredResumes = _resumes
          .where((r) =>
              r.fileName.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // TODO: Reset toàn bộ
  void reset() {
    _setState(
      isLoading: false,
      isSuccess: false,
      isDetailLoading: false,
      errorMessage: null,
      resumes: [],
      filteredResumes: [],
      defaultResume: null,
    );
  }
}
