import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

@RoutePage()
class DeleteAccountPage extends HookConsumerWidget {
  const DeleteAccountPage({super.key});

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    void Function(bool busy) setDeleting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = AppTheme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colors.bgColor,
          title: Text(
            l10n.deleteAccountDialogTitle,
            style: theme.typo.textMd.semibold.copyWith(
              color: theme.colors.contentColor,
            ),
          ),
          content: Text(
            l10n.deleteAccountDialogMessage,
            style: theme.typo.textSm.regular.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n.deleteAccountDialogAbort,
                style: theme.typo.textSm.medium.copyWith(
                  color: theme.colors.secondContentColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: UIColorsToken.neg400,
              ),
              child: Text(
                l10n.deleteAccountDialogConfirm,
                style: theme.typo.textSm.semibold.copyWith(
                  color: UIColorsToken.neg400,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    setDeleting(true);
    final ok = await ref.read(profileProvider.notifier).deleteAccount();
    if (!context.mounted) return;

    if (!ok) {
      setDeleting(false);
      return;
    }

    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;

    context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = AppTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isDeleting = useState(false);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.settingsDeleteAccountTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            kPageHorzPadding,
            kPageHorzPadding,
            kPageHorzPadding,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1014),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x55FF4C5E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deleteAccountWarningTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFFB9C2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.deleteAccountWarningBody,
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFE0B6BE),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              UIButton.primary(
                title: l10n.deleteAccountConfirm,
                fullWidth: true,
                customRadius: 18,
                backgroundColor: UIColorsToken.neg600,
                disabled: isDeleting.value,
                isBusy: isDeleting.value,
                titleStyle: theme.typo.textSm.semibold.copyWith(
                  color: UIColorsToken.white,
                ),
                onTap: isDeleting.value
                    ? null
                    : () => _confirmAndDelete(
                          context,
                          ref,
                          (busy) => isDeleting.value = busy,
                        ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
