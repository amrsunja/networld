import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/network/internet_provider.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/profile/data/datasources/profile_local_datasource.dart';
import 'package:networld/src/src/features/core/profile/data/datasources/profile_remote_datasource.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

final profileRepoProvider = Provider<ProfileRepo>(
  (ref) => ProfileRepo(
    remoteDatasource: ref.read(profileRemoteDatasourceProvider),
    localDatasource: ref.read(profileLocalDatasourceProvider),
    internetConnection: ref.read(internetProvider),
  ),
);

class ProfileRepo {
  final ProfileRemoteDatasource remoteDatasource;
  final ProfileLocalDatasource localDatasource;
  final InternetConnection internetConnection;

  ProfileRepo({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.internetConnection,
  });

  Future<SuccessOrError<ProfileModel?>> getCurrentUserProfile() async {
    return Failure.exceptionsCatcher(() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final hasInternet = await internetConnection.hasInternetAccess;

      if (hasInternet) {
        final remoteProfile = await remoteDatasource.getCurrentUserProfile();
        if (remoteProfile != null) {
          await localDatasource.saveProfile(userId, remoteProfile);
        }
      }

      return localDatasource.getProfile(userId);
    });
  }

  Future<SuccessOrError<ProfileModel?>> getProfile(String userId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getProfile(userId),
    );
  }
}
