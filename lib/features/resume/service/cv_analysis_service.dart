import 'dart:io';
import 'dart:convert';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

/// Model cho kết quả phân tích CV
class CVAnalysisResult {
  final String cvText;
  final String? strengths;
  final String? weaknesses;
  final String? overallAssessment;
  final List<String>? suggestedSkills;
  final List<JobPostingModel>? recommendedJobs;
  final bool success;
  final String? errorMessage;

  CVAnalysisResult({
    required this.cvText,
    this.strengths,
    this.weaknesses,
    this.overallAssessment,
    this.suggestedSkills,
    this.recommendedJobs,
    this.success = true,
    this.errorMessage,
  });

  factory CVAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CVAnalysisResult(
      cvText: json['cvText'] as String? ?? '',
      strengths: json['strengths'] as String?,
      weaknesses: json['weaknesses'] as String?,
      overallAssessment: json['overallAssessment'] as String?,
      suggestedSkills: (json['suggestedSkills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      recommendedJobs: (json['recommendedJobs'] as List<dynamic>?)
          ?.map((e) => JobPostingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Service để phân tích CV và lấy gợi ý công việc
class CVAnalysisService {
  final ApiService _apiService = ApiService();

  /// Phân tích CV từ file PDF
  /// 
  /// [pdfFile]: File PDF cần phân tích
  /// [userId]: ID của user
  /// 
  /// Trả về [CVAnalysisResult] với kết quả phân tích và gợi ý công việc
  Future<CVAnalysisResult> analyzeCVFromFile({
    required File pdfFile,
    required String userId,
  }) async {
    try {
      // Đọc file và convert sang base64 để gửi lên API
      final bytes = await pdfFile.readAsBytes();
      final base64File = base64Encode(bytes);
      
      // Gọi API để extract text từ PDF
      final extractResponse = await _apiService.post(
        endpoint: ApiConstants.cvAnalysisExtractText,
        body: {
          'pdfBase64': base64File,
        },
        requireAuth: true,
      );

      if (extractResponse == null) {
        throw ServerException(
          err: 'Không thể extract text từ PDF',
          type: ServerExceptionType.api,
        );
      }

      final extractResult = extractResponse as Map<String, dynamic>;
      if (extractResult['success'] != true) {
        throw ServerException(
          err: extractResult['errorMessage'] as String? ?? 'Không thể đọc được text từ PDF',
          type: ServerExceptionType.api,
        );
      }

      final cvText = extractResult['extractedText'] as String? ?? '';
      
      if (cvText.isEmpty) {
        throw ServerException(
          err: 'Không thể đọc được nội dung từ file PDF. File có thể là file ảnh hoặc PDF được bảo vệ.',
          type: ServerExceptionType.api,
        );
      }

      // Phân tích CV với text đã extract
      return await _analyzeCVText(cvText: cvText, userId: userId);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi phân tích CV: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Phân tích CV từ text
  /// 
  /// [cvText]: Text content của CV
  /// [userId]: ID của user
  /// 
  /// Trả về [CVAnalysisResult] với kết quả phân tích và gợi ý công việc
  Future<CVAnalysisResult> analyzeCVFromText({
    required String cvText,
    required String userId,
  }) async {
    return await _analyzeCVText(cvText: cvText, userId: userId);
  }

  /// Phân tích CV từ URL (CV đã lưu)
  /// 
  /// [cvUrl]: URL của CV
  /// [userId]: ID của user
  /// 
  /// Trả về [CVAnalysisResult] với kết quả phân tích và gợi ý công việc
  Future<CVAnalysisResult> analyzeCVFromUrl({
    required String cvUrl,
    required String userId,
  }) async {
    try {
      // Gọi API để extract text và phân tích CV
      final response = await _apiService.post(
        endpoint: ApiConstants.cvAnalysisAnalyze,
        body: {
          'userId': userId,
          'cvUrl': cvUrl,
        },
        requireAuth: true,
      );

      if (response == null) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API',
          type: ServerExceptionType.api,
        );
      }

      // Parse response
      final result = CVAnalysisResult.fromJson(response as Map<String, dynamic>);
      
      if (!result.success) {
        throw ServerException(
          err: result.errorMessage ?? 'Lỗi khi phân tích CV',
          type: ServerExceptionType.api,
        );
      }

      return result;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi phân tích CV từ URL: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Internal method để phân tích CV text và lấy gợi ý công việc
  Future<CVAnalysisResult> _analyzeCVText({
    required String cvText,
    required String userId,
  }) async {
    try {
      // Gọi API để phân tích CV
      final response = await _apiService.post(
        endpoint: ApiConstants.cvAnalysisAnalyze,
        body: {
          'userId': userId,
          'cvText': cvText,
        },
        requireAuth: true,
      );

      if (response == null) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API',
          type: ServerExceptionType.api,
        );
      }

      // Parse response
      final result = CVAnalysisResult.fromJson(response as Map<String, dynamic>);
      
      if (!result.success) {
        throw ServerException(
          err: result.errorMessage ?? 'Lỗi khi phân tích CV',
          type: ServerExceptionType.api,
        );
      }

      return result;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi phân tích CV: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

}

