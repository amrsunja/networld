import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/post/data/datasources/post_remote_datasource.dart';
import 'package:networld/src/src/features/core/post/ui/state_management/create_post_provider.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';

int _estimateCredits({required bool poll, required bool boost}) {
  var base = poll ? 5000 : 1000;
  if (boost) base *= 3;
  return base;
}

@RoutePage()
class CreatePostPage extends HookConsumerWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final contentCtrl = useTextEditingController();
    final pickedImage = useState<File?>(null);
    final isPoll = useState(false);
    final isBoost = useState(false);
    final pollFieldCount = useState(2);

    final pollCtrls = useMemoized(
      () => List.generate(4, (_) => TextEditingController()),
      const [],
    );

    useEffect(() {
      return () {
        for (final c in pollCtrls) {
          c.dispose();
        }
      };
    }, pollCtrls);

    final submitState = ref.watch(createPostProvider);
    final submitNotifier = ref.read(createPostProvider.notifier);
    final remote = ref.read(postRemoteDatasourceProvider);
    final appEvents = ref.read(appEventProvider);

    Future<void> openImageSheet() async {
      final height = MediaQuery.sizeOf(context).height * 0.88;
      final file = await showModalBottomSheet<File?>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: height,
              child: ColoredBox(
                color: AppTheme.of(ctx).colors.bgColor,
                child: MediaPicker(
                  onPick: (list) async {
                    if (list.isEmpty) return;
                    final f = await remote.assetToFile(list.first);
                    if (ctx.mounted && f != null) {
                      Navigator.of(ctx).pop(f);
                    }
                  },
                  mediaList: const [],
                  maxSelectingMediaCount: 1,
                  mediaCount: MediaCount.single,
                  mediaType: MediaType.image,
                ),
              ),
            ),
          );
        },
      );
      if (file != null) pickedImage.value = file;
    }

    List<String> collectPollOptions() {
      final out = <String>[];
      for (var i = 0; i < pollFieldCount.value; i++) {
        final t = pollCtrls[i].text.trim();
        if (t.isNotEmpty) out.add(t);
      }
      return out;
    }

    Future<void> onSubmit() async {
      final user = supabase.auth.currentUser;
      if (user == null) {
        appEvents.send(
          ShowErrorEvent(null, defaultMessage: l10n.errorUnauthorized),
        );
        return;
      }

      final text = contentCtrl.text.trim();
      final hasImage = pickedImage.value != null;

      if (!isPoll.value && text.isEmpty && !hasImage) {
        appEvents.send(ShowInfoMessageEvent(l10n.createPostValidationNeedBody));
        return;
      }

      List<String>? pollOptions;
      if (isPoll.value) {
        pollOptions = collectPollOptions();
        if (pollOptions.length < 2) {
          appEvents.send(ShowInfoMessageEvent(l10n.createPostValidationPoll));
          return;
        }
      }

      final ok = await submitNotifier.submit(
        content: text,
        isPoll: isPoll.value,
        pollOptions: pollOptions ?? [],
        imageFile: pickedImage.value,
        isBoosted: isBoost.value,
        userId: user.id,
      );

      if (ok && context.mounted) {
        context.router.maybePop();
      }
    }

    final credits = _estimateCredits(
      poll: isPoll.value,
      boost: isBoost.value,
    );

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.createPostTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            kPageHorzPadding,
            20,
            kPageHorzPadding,
            70
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              UIInputField(
                controller: contentCtrl,
                hintText: l10n.createPostHint,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              if (pickedImage.value != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.file(
                      pickedImage.value!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => pickedImage.value = null,
                    style: TextButton.styleFrom(
                      foregroundColor: UIColorsToken.pri350,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.createPostRemoveImage),
                  ),
                ),
              ] else
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: openImageSheet,
                    style: TextButton.styleFrom(
                      foregroundColor: UIColorsToken.pri350,
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.createPostAttachImage),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.createPostPollToggle,
                      style: theme.typo.textSm.medium.copyWith(
                        color: theme.colors.contentColor,
                      ),
                    ),
                  ),
                  UIToggle(
                    checked: isPoll.value,
                    disabled: submitState.isSubmitting,
                    onCheck: (v) => isPoll.value = v,
                  ),
                ],
              ),
              if (isPoll.value) ...[
                for (var i = 0; i < pollFieldCount.value; i++) ...[
                  const SizedBox(height: 8),
                  UIInputField(
                    controller: pollCtrls[i],
                    hintText: l10n.createPostPollOptionHint(i + 1),
                  ),
                ],
                if (pollFieldCount.value < 4)
                  UITap(
                    onTap: () {
                      if (pollFieldCount.value < 4) {
                        pollFieldCount.value++;
                      }
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          l10n.createPostAddPollOption,
                          style: theme.typo.textSm.regular.copyWith(
                            color: UIColorsToken.grey
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.createPostBoostToggle,
                      style: theme.typo.textSm.medium.copyWith(
                        color: theme.colors.contentColor,
                      ),
                    ),
                  ),
                  UIToggle(
                    checked: isBoost.value,
                    disabled: submitState.isSubmitting,
                    onCheck: (v) => isBoost.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createPostCost(credits),
                style: theme.typo.textSm.medium.copyWith(
                  color: theme.colors.secondContentColor,
                ),
              ),
              if (submitState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  submitState.errorMessage!,
                  style: theme.typo.textXs.regular.copyWith(
                    color: UIColorsToken.neg500,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              UIButton.primary(
                title: l10n.createPostSubmit,
                fullWidth: true,
                isBusy: submitState.isSubmitting,
                onTap: onSubmit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
