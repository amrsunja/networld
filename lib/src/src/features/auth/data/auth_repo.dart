import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

import 'datasources/auth_remote_datasource.dart';


final authRepoProvider = Provider<AuthRepo>(
  (ref) => AuthRepo(
    remoteDatasource: ref.read(authRemoteDataProvider),
  ),
);

class AuthRepo {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepo({
    required this.remoteDatasource,
  });

  Future<SuccessOrError<void>> loginWithGoogle() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.loginWithGoogle();
    });
  }

  Future<SuccessOrError<void>> loginWithApple() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.loginWithApple();
    });
  }

  Future<SuccessOrError<void>> logout() async {
    return await Failure.exceptionsCatcher<void>(() async {
      await remoteDatasource.logout();
    });
  }

  Future<SuccessOrError<bool>> checkAuthStatus() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.isAuthenticated();
    });
  }
}
