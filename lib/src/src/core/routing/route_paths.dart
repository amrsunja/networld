abstract class RoutePaths {
  static const root = '/';

  // Auth
  static const login = 'sign-in';
  static const onboarding = 'onboarding';

  // Main
  static const home = '';

  static const daily = 'daily';
  static const social = 'social';
  static const createPost = 'create-post';
  static const profile = 'profile';
  static const settings = 'settings';
  static const appLanguage = 'app-language';
  static const editProfileInformations = 'edit-profile-informations';
  static const deleteAccount = 'delete-account';
  static const avatars = 'avatars';
  static const notifications = 'notifications';
  static const notificationPreferences = 'notification-preferences';

  static const shop = 'shop';
  static String userProfile({String? id}) => 'user-profile/${id ?? ':userId'}';

  // Root dialog
  static String post({String? id}) => 'post/${id ?? ':id'}';
}
