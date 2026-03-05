import 'package:multiple_result/multiple_result.dart';

import '../errors/failures/failures.dart';

typedef Json = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;
/// Params type when we send http request
typedef QueryParams = Map<String, dynamic>;

/// Error = Failure | Success = <$T> | return failure or a <$T>
typedef SuccessOrError<T> = Result<T, Failure>;
