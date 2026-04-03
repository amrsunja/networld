import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/powens/data/models/powens_session_model.dart';

import '../models/recalced_net_worth_model.dart';

final powensRemoteDatasourceProvider = Provider<PowensRemoteDatasource>(
  (ref) => PowensRemoteDatasource(),
);

class PowensRemoteDatasource {
  /// Sets net worth manually (max 25_000).
  Future<RecalcedNetWorthModel> setManualNetWorth(double netWorth) async {
    final res = await supabase.functions.invoke(
      'recalc-networth',
      body: {
        'method': 'manual',
        'net_worth': netWorth,
      },
    );
    
    final data = (res.data as Json?) ?? {};
    final response = RecalcedNetWorthModel.fromJson(data);

    if (!response.success && response.error != null) {
      throw ServerException.fromErrorCode(response.error);
    }

    return response;
  }

  /// Recalculates net worth using Powens with a permanent token.
  Future<RecalcedNetWorthModel> recalcNetWorthFromPowens(
    String permanentToken,
  ) async {
    final res = await supabase.functions.invoke(
      'recalc-networth',
      body: {
        'method': 'powens',
        'powens_permanent_token': permanentToken,
      },
    );

    final data = (res.data as Json?) ?? {};
    final response = RecalcedNetWorthModel.fromJson(data);

    if (!response.success && response.error != null) {
      throw ServerException.fromErrorCode(response.error);
    }

    return response;
  }

  Future<PowensSessionModel> createPowensSession() async {
    final res = await supabase.functions.invoke('powens-create-session');
    final data = (res.data as Json?) ?? {};

    if (data['success'] != true) {
      throw ServerException.fromErrorCode(data['error'] as String?);
    }

    return PowensSessionModel.fromJson(data);
  }
}
