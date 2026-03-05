abstract class RoutePaths {
  static const root = '/';

  // Auth
  static const login = 'sign-in';
  static const onboarding = 'onboarding';

  // Main
  static const home = '';

  static const daily = 'daily';
  static const social = 'social';
  static const profile = 'profile';

  static const shop = 'shop';

  // Root dialog
  static String post({String? id}) => 'post/${id ?? ':id'}';
}
