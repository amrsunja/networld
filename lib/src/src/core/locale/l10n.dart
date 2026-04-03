import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/features/settings/ui/state_management/settings_provider.dart';

import 'gen/app_localizations.dart';

typedef AppLocale = AppLocalizations;

final l10nProvider = Provider<AppLocale>((ref) {
	// 1. initialize from the initial locale
	final locale = L10n.defaultLocale ;
  late AppLocalizations state;

	//state = lookupAppLocalizations(locale);

	// 2. create an observer to update the state
	final localSettings = ref.watch(settingsProvider).data;

	state = lookupAppLocalizations(localSettings?.locale ?? locale);
	//ref.state = lookupAppLocalizations(locale);

	return state;
});


class L10n {
	static Locale get fr => all[0];
	static Locale get en => all[1];

  static final all = [
    const Locale('fr', 'FR'),
    const Locale('en', 'EN'),
  ];

	static Locale get defaultLocale {
		final appNativeLocale = ui.PlatformDispatcher.instance.locale;
		return all.firstWhereOrNull((value) => appNativeLocale.languageCode == value.languageCode) ?? en;
	}
}
