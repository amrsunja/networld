import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(),
);

class ProfileRemoteDatasource {
  static const _tableName = 'profiles';
  static const _deleteAccountFn = 'delete-account';

  Future<ProfileModel?> getProfile(String userId) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ProfileModel.fromJson(response as Map<String, dynamic>);
  }

  Future<ProfileModel?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    return getProfile(user.id);
  }

  /// Edge Function `delete-account`: requires `{ "confirm": true }` in the body.
  Future<void> deleteMyAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException(ServerExceptionType.unauthorized);
    }

    try {
      final res = await supabase.functions.invoke(
        _deleteAccountFn,
        body: <String, dynamic>{'confirm': true},
      );

      final data = (res.data as Json?) ?? {};
      if (data['success'] == true) return;

      throw ServerException.fromErrorCode(data['error'] as String?);
    } on FunctionException catch (e) {
      final details = e.details;
      String? code;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        code = m['error'] as String? ?? m['code'] as String?;
        if (code == null && m['message'] is String) {
          code = m['message'] as String?;
        }
      }
      throw ServerException.fromErrorCode(code);
    }
  }
}
