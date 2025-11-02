import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'appwrite_client.dart';

class StorageAppwriteService {
  final AppwriteClient _appwrite = AppwriteClient();
  late final Storage _storage;

  StorageAppwriteService() {
    _storage = Storage(_appwrite.client);
  }

  // Upload file (CV, ảnh, tài liệu, ...)
  Future<aw.File> uploadFile(File file, {required String bucketId}) async {
    if (bucketId.isEmpty) {
      throw ServerException(
        err: 'BucketId không được rỗng',
        type: ServerExceptionType.config,
      );
    }

    try {
      final uploadedFile = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      return uploadedFile;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? 'Lỗi upload file Appwrite',
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  // Lấy URL public để xem file
  String getFileViewUrl(String fileId, {required String bucketId}) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? '';
    final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

    if (endpoint.isEmpty || projectId.isEmpty) {
      throw ServerException(
        err: 'Thiếu cấu hình endpoint hoặc projectId trong .env',
        type: ServerExceptionType.config,
      );
    }

    if (bucketId.isEmpty) {
      throw ServerException(
        err: 'BucketId không được rỗng',
        type: ServerExceptionType.config,
      );
    }

    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  // Xóa file
  Future<void> deleteFile(String fileId, {required String bucketId}) async {
    if (bucketId.isEmpty) {
      throw ServerException(
        err: 'BucketId không được rỗng',
        type: ServerExceptionType.config,
      );
    }

    try {
      await _storage.deleteFile(bucketId: bucketId, fileId: fileId);
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? 'Lỗi khi xóa file khỏi Appwrite',
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  // Lấy danh sách file trong bucket
  Future<List<aw.File>> listFiles({required String bucketId}) async {
    if (bucketId.isEmpty) {
      throw ServerException(
        err: 'BucketId không được rỗng',
        type: ServerExceptionType.config,
      );
    }

    try {
      final response = await _storage.listFiles(bucketId: bucketId);
      return response.files;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? 'Lỗi lấy danh sách file Appwrite',
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }
}
