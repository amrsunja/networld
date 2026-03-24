import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/routing/route_paths.dart';

import 'app_router.gr.dart';
import 'guards/auth_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final Ref ref;

  AppRouter(this.ref);


	/// General we use this route builder to enable opaque value wich is setted like true by default 
	CustomRoute customRoute({
		required PageInfo page,
		String? path,
		Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder = TransitionsBuilders.slideLeftWithFade,
		int durationInMilliseconds = 300,
		bool initial = false,
	}) => CustomRoute(
		page: page,
		path: path,
		initial: initial,
		transitionsBuilder: transitionsBuilder,
		duration: Duration(milliseconds: durationInMilliseconds)
	);

  late final authGuard = AuthGuard(ref);

	final generalSubPages = [
	];


  @override
  List<AutoRoute> get routes => [

    /// ROOT
    AutoRoute(
      path: '/',
      page: RootRoute.page,
      initial: true,
      children: [

        /// AUTH
        AutoRoute(
          path: RoutePaths.login,
          page: LoginRoute.page,
        ),

        AutoRoute(
          path: RoutePaths.onboarding,
          page: OnboardingRoute.page,
        ),

        /// Home (protected)
        AutoRoute(
          path: RoutePaths.home,
          page: HomeRouterRoute.page,
          guards: [authGuard],
          children: [

            AutoRoute(
              path: '',
              page: HomeRoute.page,
              children: [
                AutoRoute(
                  path: RoutePaths.daily,
                  page: DailyRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: DailyRoute.page),
                    ...generalSubPages
                  ]
                ),

                AutoRoute(
                  path: RoutePaths.social,
                  page: SocialRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: SocialRoute.page),
                    ...generalSubPages,
                  ]
                ),

                AutoRoute(
                  path: RoutePaths.profile,
                  page: ProfileRouterRoute.page,
                  children: [
                    AutoRoute(path: '', page: ProfileRoute.page),
                    AutoRoute(
                      path: RoutePaths.settings,
                      page: SettingsRoute.page,
                    ),
                    AutoRoute(
                      path: RoutePaths.appLanguage,
                      page: AppLanguageRoute.page,
                    ),
                    AutoRoute(
                      path: RoutePaths.editProfileInformations,
                      page: EditProfileInformationsRoute.page,
                    ),
                    AutoRoute(
                      path: RoutePaths.deleteAccount,
                      page: DeleteAccountRoute.page,
                    ),
                    ...generalSubPages
                  ]
                ),
              ]
            ),

            /*AutoRoute(
              path: RoutePaths.post(),
              page: PostDetailsRoute.page,
            ),*/

          ],
        ),
      ],
    ),
  ];
}
