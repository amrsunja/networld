// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appLanguage => 'English';

  @override
  String get l10nSuccess =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUCCESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get success_internet_connection => 'Internet connection established';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_server_failure =>
      'Something went wrong. Please check your internet connection';

  @override
  String get error_db_failure =>
      'Something went wrong. Please try again or contact us';

  @override
  String get error_internet_connection_lost => 'Internet connection is lost';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
