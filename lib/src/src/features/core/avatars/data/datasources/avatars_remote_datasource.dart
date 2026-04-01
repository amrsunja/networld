import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception_type.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final avatarsRemoteDatasourceProvider = Provider<AvatarsRemoteDatasource>(
  (ref) => AvatarsRemoteDatasource(),
);

class AvatarsRemoteDatasource {
  static const _catalogTable = 'avatar_catalog';
  static const _userAvatarsTable = 'user_avatars';
  static const _profilesTable = 'profiles';
  static const _purchaseFn = 'purchase-avatar';

  /// Fetches the full avatar catalog sorted by id.
  Future<List<AvatarCatalogModel>> fetchAvatarCatalog() async {
    final response = await supabase
        .from(_catalogTable)
        .select()
        .order('id', ascending: true);

    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(AvatarCatalogModel.fromJson)
        .toList();
  }

  /// Returns the set of avatar IDs owned by the current user.
  Future<Set<int>> fetchOwnedAvatarIds() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException(ServerExceptionType.unauthorized);
    }

    final response = await supabase
        .from(_userAvatarsTable)
        .select('avatar_id')
        .eq('user_id', user.id);

    return (response as List)
        .cast<Map<String, dynamic>>()
        .map((row) => row['avatar_id'] as int)
        .toSet();
  }

  /// Calls the `purchase-avatar` edge function.
  /// Returns the updated credit balance on success.
  Future<int> purchaseAvatar(int avatarId) async {
    try {
      final res = await supabase.functions.invoke(
        _purchaseFn,
        body: <String, dynamic>{'avatar_id': avatarId},
      );

      final data = (res.data as Json?) ?? {};
      if (data['success'] == true) {
        return (data['balance'] as int?) ?? 0;
      }

      throw ServerException.fromErrorCode(data['error'] as String?);
    } on FunctionException catch (e) {
      final details = e.details;
      String? code;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        code = m['error'] as String? ?? m['code'] as String?;
      }
      throw ServerException.fromErrorCode(code);
    }
  }

  /// Updates the user's active avatar_id on the profiles table.
  Future<void> selectAvatar(int avatarId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException(ServerExceptionType.unauthorized);
    }

    await supabase
        .from(_profilesTable)
        .update({'avatar_id': avatarId})
        .eq('id', user.id);
  }
}
