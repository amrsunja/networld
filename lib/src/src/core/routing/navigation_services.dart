import 'app_router.dart';
import 'app_router.gr.dart';

abstract class NavigationServices {
	void pop();

  void toSignIn();
  void toDaily();
  void toOnboarding();
  void toProfile();
  void toShop();
}

class NavigationServicesImpl implements NavigationServices {
	final AppRouter router;

	NavigationServicesImpl({
		required this.router
	});

  @override
  void pop() => router.pop();

  @override
  void toDaily() {
    // TODO: implement toDaily
  }

  @override
  void toOnboarding() {
    // TODO: implement toOnboarding
  }

  @override
  void toProfile() {
    // TODO: implement toProfile
  }

  @override
  void toShop() {
    router.push(const ShopRoute());
  }

  @override
  void toSignIn() {
    // TODO: implement toSignIn
  }

}
