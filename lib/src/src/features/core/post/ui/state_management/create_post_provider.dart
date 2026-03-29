import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/post/data/post_repo.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

import 'create_post_state.dart';

final createPostProvider =
    StateNotifierProvider.autoDispose<CreatePostPresenter, CreatePostState>(
  (ref) => CreatePostPresenter(
    repo: ref.read(postRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    refreshProfile: () => ref.read(profileProvider.notifier).loadProfile(),
  ),
);

class CreatePostPresenter extends Presenter<CreatePostState> {
  CreatePostPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
    required this.refreshProfile,
  }) : super(const CreatePostState());

  final PostRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;
  final Future<void> Function() refreshProfile;

  Future<bool> submit({
    required String content,
    required bool isPoll,
    required List<String> pollOptions,
    required File? imageFile,
    required bool isBoosted,
    required String userId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await repo.createPost(
      content: content.isEmpty ? null : content,
      isPoll: isPoll,
      pollOptions: isPoll ? pollOptions : null,
      imageFile: imageFile,
      isBoosted: isBoosted,
      userId: userId,
    );

    return result.when(
      (model) async {
        await refreshProfile();
        state = state.copyWith(isSubmitting: false, clearError: true);
        final message = model.status == 'review'
            ? locale.createPostSuccessReview
            : locale.createPostSuccessPublished;
        appEvents.send(ShowSuccessMessageEvent(message));
        return true;
      },
      (failure) async {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(failure, defaultMessage: locale.createPostErrorGeneric),
        );
        return false;
      },
    );
  }
}
