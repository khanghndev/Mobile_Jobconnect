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
  late final String _bucketId;

  StorageAppwriteService() {
    _storage = Storage(_appwrite.client);
    _bucketId = dotenv.env['APPWRITE_BUCKET_ID_RESUME'] ?? '';

    if (_bucketId.isEmpty) {
      throw ServerException(
        err: 'Thiếu APPWRITE_BUCKET_ID trong file .env',
        type: ServerExceptionType.config,
      );
    }
  }

  //TODO: Upload file (CV, hình ảnh, tài liệu,...)
  Future<aw.File> uploadFile(File file) async {
    try {
      final uploadedFile = await _storage.createFile(
        bucketId: _bucketId,
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

  //TODO: Lấy URL để xem file (public view)
  String getFileViewUrl(String fileId) {
    try {
      final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? '';
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

      if (endpoint.isEmpty || projectId.isEmpty) {
        throw ServerException(
          err: 'Thiếu cấu hình endpoint hoặc projectId trong .env',
          type: ServerExceptionType.config,
        );
      }

      return '$endpoint/storage/buckets/$_bucketId/files/$fileId/view?project=$projectId';
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Xóa file
  Future<void> deleteFile(String fileId) async {
    try {
      await _storage.deleteFile(bucketId: _bucketId, fileId: fileId);
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

  //TODO: Lấy danh sách file trong bucket
  Future<List<aw.File>> listFiles() async {
    try {
      final response = await _storage.listFiles(bucketId: _bucketId);
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
