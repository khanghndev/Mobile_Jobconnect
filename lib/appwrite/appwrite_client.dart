import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';

class AppwriteClient {
  static final AppwriteClient _instance = AppwriteClient._internal();

  late final Client client;
  late final Account account;
  late final Storage storage;

  //Singleton
  factory AppwriteClient() => _instance;

  AppwriteClient._internal() {
    final String? endpoint = dotenv.env['APPWRITE_ENDPOINT'];
    final String? projectId = dotenv.env['APPWRITE_PROJECT_ID'];

    if (endpoint == null || projectId == null || endpoint.isEmpty || projectId.isEmpty) {
      throw ServerException(
        err: 'Appwrite cấu hình thiếu trong file .env — cần có:\nAPPWRITE_ENDPOINT, APPWRITE_PROJECT_ID',
        type: ServerExceptionType.config,
      );
    }

    client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId)
      ..setSelfSigned(status: true);
    account = Account(client);
    storage = Storage(client);
  }
  
}