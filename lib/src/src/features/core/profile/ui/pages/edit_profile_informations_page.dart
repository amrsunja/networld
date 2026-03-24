import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

@RoutePage()
class EditProfileInformationsPage extends HookConsumerWidget {
  const EditProfileInformationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final usernameController = useTextEditingController();
    final fieldError = useState<String?>(null);

    useEffect(() {
      final username = profileState.profile?.username;
      if (username != null && usernameController.text.isEmpty) {
        usernameController.text = username;
      }
      return null;
    }, [profileState.profile?.username]);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.settingsPersonalInformationTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kPageHorzPadding),
        children: [
          Text(
            l10n.editProfileDescription,
            style: theme.typo.textSm.regular.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
          const SizedBox(height: 24),
          UIInputField(
            label: l10n.editProfileUsernameLabel,
            hintText: l10n.editProfileUsernameHint,
            controller: usernameController,
            errorText: fieldError.value,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            onChanged: (_) {
              if (fieldError.value != null) {
                fieldError.value = null;
              }
            },
          ),
          const SizedBox(height: 28),
          UIButton.primary(
            title: l10n.editProfileSaveChanges,
            fullWidth: true,
            isBusy: profileState.isSavingProfile,
            customRadius: 12,
            onTap: () async {
              fieldError.value = null;
              final result = await profileNotifier.saveProfileUsername(
                usernameController.text,
              );
              if (!context.mounted) return;
              if (result.validationError != null) {
                fieldError.value = result.validationError;
                return;
              }
              if (result.shouldPop) {
                context.router.maybePop();
              }
            },
          ),
        ],
      ),
    );
  }
}
