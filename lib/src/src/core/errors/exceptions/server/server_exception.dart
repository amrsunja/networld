import 'server_exception_type.dart';

class ServerException implements Exception {
  final ServerExceptionType type;
  final String? rawError; // pour le debug

  const ServerException(this.type, {this.rawError});

  factory ServerException.fromErrorCode(String? errorCode) {
    return ServerException(
      ServerExceptionType.fromString(errorCode),
      rawError: errorCode,
    );
  }

  @override
  String toString() => 'ApiException(${type.name}, raw: $rawError)';
}
