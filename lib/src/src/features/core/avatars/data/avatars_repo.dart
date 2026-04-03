import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/avatars/data/datasources/avatars_remote_datasource.dart';
import 'package:brokies/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';

final avatarsRepoProvider = Provider<AvatarsRepo>(
  (ref) => AvatarsRepo(
    remoteDatasource: ref.read(avatarsRemoteDatasourceProvider),
  ),
);

class AvatarsRepo {
  final AvatarsRemoteDatasource remoteDatasource;

  AvatarsRepo({required this.remoteDatasource});

  Future<SuccessOrError<List<AvatarCatalogModel>>> fetchAvatarCatalog() async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.fetchAvatarCatalog(),
    );
  }

  Future<SuccessOrError<Set<int>>> fetchOwnedAvatarIds() async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.fetchOwnedAvatarIds(),
    );
  }

  /// Purchases an avatar. Returns the updated credit balance.
  Future<SuccessOrError<int>> purchaseAvatar(int avatarId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.purchaseAvatar(avatarId),
    );
  }

  Future<SuccessOrError<void>> selectAvatar(int avatarId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.selectAvatar(avatarId),
    );
  }
}
