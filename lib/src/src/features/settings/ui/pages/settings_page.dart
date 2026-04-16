import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/config/app_config.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';
import 'package:brokies/src/src/core/routing/app_router.gr.dart';
import 'package:brokies/src/src/core/utils/constants/constants.dart';
import 'package:brokies/src/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:brokies/src/src/features/settings/ui/widgets/settings_action_card.dart';
import 'package:brokies/src/src/features/settings/ui/widgets/settings_logout_button.dart';
import 'package:brokies/src/src/features/settings/ui/widgets/settings_section_title.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.settingsTooltip,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              SettingsSectionTitle(title: l10n.settingsAccountSectionTitle),
              const SizedBox(height: 18),
              SettingsActionCard(
                icon: Icons.language_rounded,
                title: l10n.settingsAppLanguageCardTitle,
                subtitle: l10n.settingsAppLanguageCardSubtitle,
                onTap: () => context.router.push(const AppLanguageRoute()),
              ),
              const SizedBox(height: 14),
              SettingsActionCard(
                icon: Icons.notifications_none_rounded,
                title: l10n.settingsNotificationsTitle,
                subtitle: l10n.settingsNotificationsSubtitle,
                onTap: () => context.router.push(
                  const NotificationPreferencesRoute(),
                ),
              ),
              const SizedBox(height: 14),
              SettingsActionCard(
                icon: Icons.shield_outlined,
                title: l10n.settingsPrivacyPolicyTitle,
                subtitle: l10n.settingsPrivacyPolicySubtitle,
                onTap: () => _openExternalLink(context, l10n, kPrivacyPolicyUrl),
              ),
              const SizedBox(height: 14),
              SettingsActionCard(
                icon: Icons.description_outlined,
                title: l10n.settingsTermsOfUseTitle,
                subtitle: l10n.settingsTermsOfUseSubtitle,
                onTap: () => _openExternalLink(context, l10n, kTermsOfUseUrl),
              ),
              const SizedBox(height: 14),
              SettingsActionCard(
                icon: Icons.contact_support_outlined,
                title: l10n.settingsContactTitle,
                subtitle: l10n.settingsContactSubtitle,
                onTap: () => _openExternalLink(context, l10n, kWebsiteUrl),
              ),
              const SizedBox(height: 12),
              SettingsActionCard(
                icon: Icons.delete_forever_outlined,
                title: l10n.settingsDeleteAccountTitle,
                subtitle: l10n.settingsDeleteAccountSubtitle,
                isDestructive: true,
                trailing: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF5D66),
                  size: 34,
                ),
                onTap: () => context.router.push(const DeleteAccountRoute()),
              ),
              const SizedBox(height: 30),
              SettingsLogoutButton(
                label: l10n.settingsLogout,
                isLoading: authState.isGoogleLoading || authState.isAppleLoading,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.router.replaceAll(const [RootRoute()]);
                  }
                },
              ),
              const SizedBox(height: 130),
              Text(
                '${l10n.settingsBrandFooter}: ${AppConfig.shared.appVersion}',
                textAlign: TextAlign.center,
                style: theme.typo.textXs.bold.copyWith(
                  color: UIColorsToken.neu300,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExternalLink(
    BuildContext context,
    AppLocalizations l10n,
    String url,
  ) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCouldNotOpenLink)),
      );
    }
  }
}
