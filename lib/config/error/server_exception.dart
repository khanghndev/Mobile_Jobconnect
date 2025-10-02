

import 'package:job_connect/config/enum/server_exception_type.dart';

class ServerException implements Exception {
  final String err;
  final ServerExceptionType type;

  ServerException({required this.err, this.type = ServerExceptionType.api});

  @override
  String toString() => err;
}
