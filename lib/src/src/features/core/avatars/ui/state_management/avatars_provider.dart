import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/avatars/data/avatars_repo.dart';
import 'package:networld/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

import 'avatars_state.dart';

final avatarsProvider =
    StateNotifierProvider.autoDispose<AvatarsPresenter, AvatarsState>(
  (ref) => AvatarsPresenter(
    repo: ref.read(avatarsRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    profileNotifier: ref.read(profileProvider.notifier),
  ),
);

/// Global cached avatar catalog — fetched once and kept alive.
final avatarCatalogProvider =
    FutureProvider<List<AvatarCatalogModel>>((ref) async {
  final repo = ref.read(avatarsRepoProvider);
  final result = await repo.fetchAvatarCatalog();
  return result.when(
    (catalog) => catalog,
    (error) => throw error,
  );
});

class AvatarsPresenter extends Presenter<AvatarsState> {
  final AvatarsRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;
  final ProfilePresenter profileNotifier;

  AvatarsPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
    required this.profileNotifier,
  }) : super(const AvatarsState());

  /// Loads catalog + owned avatars in parallel.
  /// Reads initial credits and avatarId from the existing profile state.
  Future<void> load() async {
    final profile = profileNotifier.state.profile;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentAvatarId: profile?.avatarId ?? 1,
      userCredits: profile?.credits ?? 0,
    );

    final results = await Future.wait([
      repo.fetchAvatarCatalog(),
      repo.fetchOwnedAvatarIds(),
    ]);

    final catalogResult = results[0];
    final ownedResult = results[1];

    catalogResult.when(
      (catalog) {
        ownedResult.when(
          (owned) {
            state = state.copyWith(
              isLoading: false,
              catalog: catalog as List<AvatarCatalogModel>,
              ownedAvatarIds: owned as Set<int>,
            );
          },
          (error) {
            state = state.copyWith(
              isLoading: false,
              catalog: catalog as List<AvatarCatalogModel>,
              errorMessage: error.toMessage(locale),
            );
          },
        );
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to load avatars'),
        );
      },
    );
  }

  /// Purchases an avatar via the edge function, then updates local state.
  Future<void> purchaseAvatar(int avatarId) async {
    if (state.purchasingAvatarId != null) return;
    state = state.copyWith(purchasingAvatarId: avatarId);

    final result = await repo.purchaseAvatar(avatarId);

    result.when(
      (newBalance) {
        state = state.copyWith(
          purchasingAvatarId: null,
          ownedAvatarIds: {...state.ownedAvatarIds, avatarId},
          userCredits: newBalance,
        );
      },
      (error) {
        state = state.copyWith(purchasingAvatarId: null);
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Purchase failed'),
        );
      },
    );
  }

  /// Selects an already-owned avatar as the active one.
  Future<void> selectAvatar(int avatarId) async {
    if (state.purchasingAvatarId != null) return;
    if (avatarId == state.currentAvatarId) return;

    state = state.copyWith(purchasingAvatarId: avatarId);

    final result = await repo.selectAvatar(avatarId);

    result.when(
      (_) {
        state = state.copyWith(
          purchasingAvatarId: null,
          currentAvatarId: avatarId,
        );
        profileNotifier.loadProfile();
      },
      (error) {
        state = state.copyWith(purchasingAvatarId: null);
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Could not select avatar'),
        );
      },
    );
  }

  /// Resets the avatar back to the default (id = 1).
  Future<void> removeAvatar() async {
    await selectAvatar(1);
  }
}
