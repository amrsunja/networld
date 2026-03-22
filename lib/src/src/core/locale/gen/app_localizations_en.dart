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
  String get errorUnauthorized =>
      'You are not authorized. Please log in again.';

  @override
  String get errorInsufficientCredits =>
      'You do not have enough credits to perform this action.';

  @override
  String get errorNetWorthRequired =>
      'Please enter your net worth to continue.';

  @override
  String get errorManualLimitUsePowens =>
      'Manual entry is limited to 25,000 €. Connect your bank with Powens to go further.';

  @override
  String get errorPowensSession =>
      'We could not start the secure Powens session. Please try again.';

  @override
  String get errorPowensPermanentTokenRequired =>
      'Your bank connection has expired. Please reconnect your bank with Powens.';

  @override
  String get errorProfileNotFound =>
      'We could not find your profile. Please try again.';

  @override
  String get errorAlreadyClaimedToday =>
      'You already claimed this reward today.';

  @override
  String get errorMissionNotFound => 'This mission is no longer available.';

  @override
  String get errorUnknown => 'An unknown error occurred. Please try again.';

  @override
  String get dailySurveyOfTheDay => 'Survey of the day';

  @override
  String get dailySurveyGiftClaimed => 'Daily reward claimed';

  @override
  String get dailyClaim => 'Claim';

  @override
  String get dailyClaimed => 'Claimed ✓';

  @override
  String get dailyVoteFirst => 'Vote first';

  @override
  String get dailyMissions => 'Daily Missions';

  @override
  String get dailyCollect => 'Collect';

  @override
  String get dailyOpenLink => 'Open';

  @override
  String get dailyMissionStart => 'Start';

  @override
  String get dailyInProgress => 'In progress...';

  @override
  String dailyCreditsAdded(int count) {
    return '+$count credits added!';
  }

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
