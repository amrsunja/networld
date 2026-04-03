import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_result_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/mission_model.dart';

part 'daily_state.freezed.dart';

@freezed
abstract class DailyState with _$DailyState {
  const factory DailyState({
    @Default(false) bool isLoading,
    @Default(false) bool isVoting,
    DailyPollModel? poll,
    int? userVotedOptionId,
    @Default([]) List<DailyPollResultModel> results,
    String? errorMessage,
    @Default(false) bool isLoadingMissions,
    @Default([]) List<MissionModel> missions,
    @Default([]) List<String> claimedMissionRefIds,
    String? missionsErrorMessage,
    String? claimingMissionId,
    /// Set after user opens external link; cleared when 5s cooldown starts on resume.
    String? awaitingResumeMissionId,
    /// 5s countdown after resume (or in-app for linkless missions) before auto-claim.
    String? cooldownMissionId,
  }) = _DailyState;
}
