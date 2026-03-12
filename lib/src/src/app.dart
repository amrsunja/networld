// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/providers/routing/navigation_services_provider.dart';
import 'package:networld/src/src/core/providers/widgets/scaffold_messenger_provider.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/app_theme_type.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/features/core/internet_connection/ui/state_management/internet_connection_provider.dart';
import 'package:networld/src/src/features/settings/ui/state_management/settings_provider.dart';

import 'core/utils/extensions/build_context_extensions.dart';


class App extends StatefulHookConsumerWidget {
	const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {

	@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
		// Send firebase messaging device token after all resuming of app
		if (state == AppLifecycleState.resumed) {
			// remove app icon badge
			//AppBadgePlus.updateBadge(0);

			//if (mounted) {
				//sendPushNotifDeviceToken();
			//}
		}
    super.didChangeAppLifecycleState(state);
  }

	Future<void> sendPushNotifDeviceToken() async {
		//if (await Permission.notification.isGranted) {
			//ref.read(notificationsProvider.notifier).sendFCMToken();
		//}
	}

	@override
	Widget build(BuildContext context) {
    // Listen to app events
    ref.watch(appEventsListenerProvider);
    ref.watch(internetConnectionProvider);

		final appSettings = ref.watch(settingsProvider).data;
		final appRouter = ref.read(navigationServicesProvider);

		useEffect(() {
		  WidgetsBinding.instance.addObserver(this);

			Future.microtask(() async {
        // init push notifications
        //await ref.read(firebaseServicesProvider).initPushNotifications();
        //await sendPushNotifDeviceToken();

			  await ref.read(settingsProvider.notifier).initLocalSettings();
			});

			return null;
		}, []);


    final theme = useMemoized(() {
      final systemTheme = context.isDarkMode ? UIThemeData.dark() : UIThemeData.dark();

      if (appSettings == null) return systemTheme;


      switch (appSettings.themeMode) {
        case AppThemeType.system:
          return systemTheme;
        case AppThemeType.dark:
          return UIThemeData.dark();
        case AppThemeType.light:
          return UIThemeData.dark();
      }
    }, [appSettings?.themeMode]);

		return AppTheme(
			data: theme,
			child: MaterialApp.router(
				theme: ThemeData(
					scaffoldBackgroundColor: theme.colors.bgColor,
          sliderTheme: SliderThemeData(
            padding: EdgeInsets.zero,
            activeTrackColor: UIColorsToken.neu50,
            inactiveTrackColor: UIColorsToken.black,
            thumbColor: UIColorsToken.white,
          ),
					appBarTheme: AppBarTheme(
						backgroundColor: Colors.transparent,
						shadowColor: Colors.transparent,
						surfaceTintColor: UIColorsToken.white,
						elevation: 0,
						titleSpacing: 0,
						scrolledUnderElevation: 0.0,
					),
					// Change splash effect colors
					splashColor: UIColorsToken.pri100,
					highlightColor: UIColorsToken.pri100,
					hoverColor: UIColorsToken.pri100,
				),
				title: kAppName,
			  debugShowCheckedModeBanner: false,
				supportedLocales: L10n.all,
		  	locale: appSettings?.locale,
				localizationsDelegates: AppLocale.localizationsDelegates,
			  scaffoldMessengerKey: ref.read(scaffoldMessengerProvider),
				routerConfig: appRouter.router.config(
          //deepLinkTransformer: DeepLink.prefixStripper('/app'),
					//deepLinkBuilder: DeepLinksServices.navigateDeepLink
        ),
			),
		);
	}
}
