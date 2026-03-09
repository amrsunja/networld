import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(),
);

class ProfileRemoteDatasource {
  static const _tableName = 'profiles';

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
}
