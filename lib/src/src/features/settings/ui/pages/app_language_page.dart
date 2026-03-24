import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/settings/ui/state_management/settings_provider.dart';
import 'package:networld/src/src/features/settings/ui/widgets/settings_checkbox_tile_widget.dart';

@RoutePage()
class AppLanguagePage extends ConsumerWidget {
  const AppLanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);

    final effectiveLanguageCode = settingsState.data?.locale?.languageCode ??
        L10n.defaultLocale.languageCode;

    Future<void> changeLang(Locale lang) async {
      if (effectiveLanguageCode == lang.languageCode) return;
      await settingsNotifier.changeAppLanguage(lang);
    }

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.settingsAppLanguageTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: kPageHorzPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsCheckboxTileWidget(
              isSelected: effectiveLanguageCode == L10n.fr.languageCode,
              leading: L10n.fr.languageCode,
              title: "Français",
              onTap: () async => changeLang(L10n.fr),
            ),

            const SizedBox(height: 10),
            SettingsCheckboxTileWidget(
              isSelected: effectiveLanguageCode == L10n.en.languageCode,
              leading: L10n.en.languageCode,
              title: "English",
              onTap: () async => changeLang(L10n.en),
            ),
          ],
        ),
      ),
    );
  }
}
