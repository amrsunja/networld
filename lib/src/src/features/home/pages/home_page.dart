import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/app_vibrations.dart';


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
					final locale = ref.watch(l10nProvider);
					return Scaffold(
						extendBody: true,
						bottomNavigationBar: Theme(
							// for removing splash effect on icon tap
							data: ThemeData(
					      splashColor: Colors.transparent,
					      highlightColor: Colors.transparent,
							),
							child: UINavBar(
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
						),
						body: SafeArea(
						  child: FadeTransition(
						  	alwaysIncludeSemantics: true,
						  	opacity: animation,
						  	child: child,
						  ),
						)
					).animate(effects: [FadeEffect(duration: Durations.long3)]);
				},
			)
		);
	}
}
