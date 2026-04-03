import 'package:hooks_riverpod/legacy.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/network/internet_provider.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';

import 'internet_connection_state.dart';

final internetConnectionProvider = StateNotifierProvider<InternetConnectionNotifier, InternetConnectionState >(
	(ref) => InternetConnectionNotifier(
		appEvents: ref.read(appEventProvider),
		locale: ref.read(l10nProvider),
		internet: ref.read(internetProvider),
	)
);

class InternetConnectionNotifier extends StateNotifier<InternetConnectionState> {
	final AppEvents appEvents;
	final AppLocale locale;
	final InternetConnection internet;

	InternetConnectionNotifier({
		required this.appEvents,
		required this.locale,
		required this.internet,
	}) : super(InternetConnectionState(isConnected: true)) {
		_listenInternetConnection();
	}

	void _listenInternetConnection() {
		internet.onStatusChange.listen((InternetStatus status) async {
			final isConnected = status == InternetStatus.connected;
			//if (isConnected == state.isConnected) return ;

			if (isConnected) {
        // Save all cached book lessons progresses
        // It will reinitialize our last reading book at the server if we are changed it localy before
        if (!state.isConnected) {
			    appEvents.send(ShowSuccessMessageEvent(locale.success_internet_connection));
        }

			} else {
			  appEvents.send(ShowErrorEvent(null, defaultMessage: locale.error_internet_connection_lost));
			}

			state = state.copyWith(isConnected: isConnected);
		});
	}
}
