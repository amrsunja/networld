import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/features/core/powens/ui/pages/set_net_worth_page.dart';
import 'package:networld/src/src/features/onboarding/ui/pages/onboarding_completed_page.dart';

@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();

    // Add new onboarding pages here in the desired order.
    final pages = useMemoized(() => [
      SetNetWorthPage(
        onFinish: (context) {
          pageController.nextPage(
            duration: Duration(
              milliseconds: 500
            ), 
            curve: Curves.fastOutSlowIn
          );
        },
      ),
      OnboardingCompletedPage(),
    ]);

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
    );
  }
}

