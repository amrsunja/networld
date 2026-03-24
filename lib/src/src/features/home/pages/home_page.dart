import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/providers/routing/navigation_services_provider.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/app_vibrations.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';


@RoutePage()
class HomePage extends StatefulHookConsumerWidget {
	const HomePage({
		super.key,
	});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

	@override
	Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    useEffect(() {
      Future.microtask(() async {
        await ref.read(profileProvider.notifier).loadProfile();
      });
      return null;
    }, []);

    if (!(profileState.profile?.onboardingCompleted ?? true)) {
      ref.read(navigationServicesProvider).router.replaceAll([OnboardingRoute()]);
    }

		return Scaffold(
			body: AutoTabsRouter(
				lazyLoad: true,
		    duration: const Duration(milliseconds: 300),
				routes: const [
					DailyRouterRoute(),
					SocialRouterRoute(),
					ProfileRouterRoute(),
				],
				transitionBuilder: (context, child, animation) {
					final tabsRouter = context.tabsRouter;
					//final locale = ref.watch(l10nProvider);
					return Scaffold(
						extendBody: true,
						/*bottomNavigationBar: Theme(
							// for removing splash effect on icon tap
							data: ThemeData(
					      splashColor: Colors.transparent,
					      highlightColor: Colors.transparent,
							),
							//child: ,
						),*/
						body: SafeArea(
            top: false,
						  child: Stack(
                alignment: .bottomCenter,
						    children: [
						      FadeTransition(
						      	alwaysIncludeSemantics: true,
						      	opacity: animation,
						      	child: child,
						      ),
                  UINavBar(
                    currentPage: tabsRouter.activeIndex,
                    onPageChange: (index) {
                      AppVibrations.buttonClick();
                      if (index == tabsRouter.activeIndex) {
                        tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
                        // if it is feed route, reset scroll position
                        /*if (index == 0)
                          ref.read(feedProvider.notifier).feedScroll.animateTo(
                            0.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn
                          );*/
                      }
                      tabsRouter.setActiveIndex(index);
                    },
                  )
						    ],
						  ),
						)
					).animate(effects: [FadeEffect(duration: Durations.long3)]);
				},
			)
		);
	}
}
