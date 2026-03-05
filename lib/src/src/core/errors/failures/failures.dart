import 'package:flutter/widgets.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../locale/l10n.dart';
import '../../utils/typedefs.dart';
import '../exceptions/cache/cache_exception.dart';
import '../exceptions/database/database_exception.dart';

abstract class Failure {
  static Future<SuccessOrError<T>> exceptionsCatcher<T>(
    Future<T> Function() onSuccess,
  ) async {
    try {
      return Result.success(await onSuccess());
    } on CacheException catch (e) {
      return Result.error(CacheFailure(exception: e));
    } on DatabaseException catch (e) {
      return Result.error(DatabaseFailure(exception: e));
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(UnknownFailure(exception: e));
    }
  }

  String toMessage(AppLocale locale);
}

class CacheFailure extends Failure {
  final CacheException exception;
  CacheFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    return 'CacheFailure: - ${exception.message}';
  }
}

class DatabaseFailure extends Failure {
  final DatabaseException exception;
  DatabaseFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    //return 'DatabaseFailure: ${exception.data} - ${exception.message}';
    debugPrint('DatabaseFailure: ${exception.data} - ${exception.message}');
    return 'Db error';
  }
}

class UnknownFailure extends Failure {
  final Object? exception;
  UnknownFailure({this.exception});

  @override
  String toMessage(AppLocale locale) {
    return 'Unknown error';
  }
}
