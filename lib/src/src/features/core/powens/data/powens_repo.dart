import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/powens/data/datasources/powens_remote_datasource.dart';
import 'package:networld/src/src/features/core/powens/data/models/powens_session_model.dart';
import 'package:networld/src/src/features/core/powens/data/models/recalced_net_worth_model.dart';

final powensRepoProvider = Provider<PowensRepo>(
  (ref) => PowensRepo(
    remoteDatasource: ref.read(powensRemoteDatasourceProvider),
  ),
);

class PowensRepo {
  final PowensRemoteDatasource remoteDatasource;

  PowensRepo({required this.remoteDatasource});

  Future<SuccessOrError<PowensSessionModel>> createPowensSession() async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.createPowensSession(),
    );
  }

  Future<SuccessOrError<RecalcedNetWorthModel>> setManualNetWorth(
    double netWorth,
  ) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.setManualNetWorth(netWorth),
    );
  }

  Future<SuccessOrError<RecalcedNetWorthModel>> recalcNetWorthFromPowens(
    String permanentToken,
  ) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.recalcNetWorthFromPowens(permanentToken),
    );
  }
}
