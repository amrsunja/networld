import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/daily/data/datasources/daily_remote_datasource.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_result_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/mission_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/previous_pulse_entry.dart';

final dailyRepoProvider = Provider<DailyRepo>(
  (ref) => DailyRepo(remoteDatasource: ref.read(dailyRemoteDatasourceProvider)),
);

class DailyRepo {
  final DailyRemoteDatasource remoteDatasource;

  DailyRepo({required this.remoteDatasource});

  Future<SuccessOrError<({DailyPollModel poll, int? userVotedOptionId})?>> getActivePollWithUserState() async {
    return Failure.exceptionsCatcher(remoteDatasource.getActivePollWithUserState);
  }

  Future<SuccessOrError<int?>> getUserVote(String pollId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getUserVote(pollId),
    );
  }

  Future<SuccessOrError<void>> castVote(String pollId, int optionId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.castVote(pollId, optionId),
    );
  }

  Future<SuccessOrError<List<DailyPollResultModel>>> getPollResults(String pollId) async {
    return Failure.exceptionsCatcher(
      () => remoteDatasource.getPollResults(pollId),
    );
  }

  Future<SuccessOrError<List<MissionModel>>> getMissionsForToday() async {
    return Failure.exceptionsCatcher(remoteDatasource.getMissionsForToday);
  }

  Future<SuccessOrError<Set<String>>> getClaimedMissionRefIdsToday() async {
    return Failure.exceptionsCatcher(remoteDatasource.getClaimedMissionRefIdsToday);
  }

  Future<SuccessOrError<int>> claimMissionReward(String missionId) async {
    return Failure.exceptionsCatcher(() async {
      final result = await remoteDatasource.claimMissionReward(missionId);
      return result.creditsAwarded ?? 0;
    });
  }

  Future<SuccessOrError<List<PreviousPulseEntry>>> getPreviousPulses() async {
    return Failure.exceptionsCatcher(() async {
      final polls = await remoteDatasource.getPreviousPolls();
      if (polls.isEmpty) return [];

      final entries = await Future.wait(
        polls.map((poll) async {
          final results = await remoteDatasource.getPollResults(poll.id);
          return PreviousPulseEntry(poll: poll, results: results);
        }),
      );
      return entries;
    });
  }
}
