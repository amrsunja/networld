part 'cache_exception_type.dart';

class CacheException implements Exception {
	final CacheExceptionType type;
	final String message;

	const CacheException({
		required this.type,
		required this.message,
	});
}
