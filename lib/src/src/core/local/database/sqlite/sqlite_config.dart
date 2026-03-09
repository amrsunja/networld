abstract class SQLiteConfig {
  static const String settingsTableName = 'settings';
  static const String profilesTableName = 'profiles';

  // Settings table rows
  static String languageCodeKey = 'language_code';
  static String countryCodeKey = 'country_code';
  static String themeModeKey = 'theme_mode';

  // Profiles table rows
  static const String profileUserIdKey = 'user_id';
  static const String profileDataKey = 'data';
}
