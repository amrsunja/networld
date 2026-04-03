import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/features/auth/ui/state_management/auth_provider.dart';

import '../app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final Ref ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {

    final state = ref.read(authProvider);

    if (state.isAuthorized) {
      /*if (state.user.showOnboarding) {
        router.replaceAll([OnboardingRoute()]);
        return ;
      }*/
      resolver.next();
    } else {
      router.replaceAll([LoginRoute()]);
    }
  }
}
