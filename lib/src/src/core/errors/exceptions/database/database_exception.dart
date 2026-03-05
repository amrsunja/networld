part 'database_exception_type.dart';

class DatabaseException implements Exception {
	final DatabaseExceptionType type;
	final String message;
	final dynamic data;

	const DatabaseException ({
		required this.type,
		required this.message,
		this.data,
	});
}
