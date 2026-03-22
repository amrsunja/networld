import 'dart:async';

import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';

import '../../data/daily_repo.dart';
import 'daily_state.dart';

final dailyProvider = StateNotifierProvider.autoDispose<DailyPresenter, DailyState>(
  (ref) => DailyPresenter(
    repo: ref.read(dailyRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class DailyPresenter extends Presenter<DailyState> {
  DailyPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
  }) : super(const DailyState());

  final DailyRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;

  static const _cooldownDuration = Duration(seconds: 5);

  Timer? _cooldownTimer;

  bool _isMissionBusy(String missionId) {
    return state.claimedMissionRefIds.contains(missionId) ||
        state.claimingMissionId == missionId ||
        state.cooldownMissionId == missionId ||
        state.awaitingResumeMissionId == missionId;
  }

  /// Call after [launchUrl] returned true — user is in the browser; we wait for [onAppResumedAfterMissionLink].
  void onMissionLinkLaunched(String missionId) {
    if (state.claimedMissionRefIds.contains(missionId)) return;
    if (state.cooldownMissionId != null || state.claimingMissionId != null) return;
    state = state.copyWith(awaitingResumeMissionId: missionId);
  }

  /// When the app resumes from background (user returned from the browser).
  void onAppResumedAfterMissionLink() {
    final id = state.awaitingResumeMissionId;
    if (id == null) return;
    if (state.claimedMissionRefIds.contains(id)) {
      state = state.copyWith(awaitingResumeMissionId: null);
      return;
    }
    state = state.copyWith(awaitingResumeMissionId: null);
    _startCooldownThenClaim(id);
  }

  /// Missions without a URL: same 5s delay, then auto-claim (in-app).
  void startCooldownForLinklessMission(String missionId) {
    if (_isMissionBusy(missionId)) return;
    _startCooldownThenClaim(missionId);
  }

  void _startCooldownThenClaim(String missionId) {
    _cooldownTimer?.cancel();
    state = state.copyWith(cooldownMissionId: missionId);
    _cooldownTimer = Timer(_cooldownDuration, () {
      _cooldownTimer = null;
      unawaited(claimMission(missionId));
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> loadPoll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final pollResult = await repo.getActivePollWithUserState();
    await pollResult.when(
      (data) async {
        if (data == null) {
          state = state.copyWith(isLoading: false, poll: null, userVotedOptionId: null);
          return;
        }

        final poll = data.poll;
        final userVotedOptionId = data.userVotedOptionId;

        state = state.copyWith(
          poll: poll,
          userVotedOptionId: userVotedOptionId,
        );

        if (userVotedOptionId != null) {
          await _fetchResultsAndApply(poll.id);
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to load daily poll'),
        );
      },
    );
  }

  Future<void> _fetchResultsAndApply(String pollId) async {
    final result = await repo.getPollResults(pollId);
    result.when(
      (results) {
        state = state.copyWith(isLoading: false, results: results);
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
      },
    );
  }

  Future<void> castVote(int optionId) async {
    final poll = state.poll;

    if (poll == null || state.userVotedOptionId != null) return;

    state = state.copyWith(isVoting: true, errorMessage: null);

    final voteResult = await repo.castVote(poll.id, optionId);
    await voteResult.when(
      (_) async {
        await _fetchResultsAndApply(poll.id);
        state = state.copyWith(isVoting: false, userVotedOptionId: optionId);
      },
      (error) {
        state = state.copyWith(
          isVoting: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to submit vote'),
        );
      },
    );
  }

  Future<void> loadMissions() async {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    state = state.copyWith(
      isLoadingMissions: true,
      missionsErrorMessage: null,
      awaitingResumeMissionId: null,
      cooldownMissionId: null,
    );

    final missionsResult = await repo.getMissionsForToday();
    await missionsResult.when(
      (missions) async {
        final claimedResult = await repo.getClaimedMissionRefIdsToday();
        claimedResult.when(
          (claimed) {
            state = state.copyWith(
              isLoadingMissions: false,
              missions: missions,
              claimedMissionRefIds: claimed.toList(),
            );
          },
          (error) {
            state = state.copyWith(
              isLoadingMissions: false,
              missions: missions,
              missionsErrorMessage: error.toMessage(locale),
            );
            appEvents.send(
              ShowErrorEvent(error, defaultMessage: 'Failed to load mission claims'),
            );
          },
        );
      },
      (error) {
        state = state.copyWith(
          isLoadingMissions: false,
          missionsErrorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to load missions'),
        );
      },
    );
  }

  Future<void> claimMission(String missionId) async {
    if (state.claimingMissionId != null) return;

    state = state.copyWith(
      claimingMissionId: missionId,
      cooldownMissionId: null,
    );

    final result = await repo.claimMissionReward(missionId);
    result.when(
      (credits) {
        final next = [...state.claimedMissionRefIds];
        if (!next.contains(missionId)) next.add(missionId);
        state = state.copyWith(
          claimingMissionId: null,
          claimedMissionRefIds: next,
        );
        appEvents.send(
          ShowSuccessMessageEvent(locale.dailyCreditsAdded(credits)),
        );
      },
      (error) {
        state = state.copyWith(claimingMissionId: null);
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to claim mission'),
        );
      },
    );
  }
}
