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
  String get errorInvalidPostType => 'This post type is not valid.';

  @override
  String get errorPollRequiresTwoOptions =>
      'A poll needs at least two options.';

  @override
  String get createPostTitle => 'New post';

  @override
  String get createPostHint => 'What do you want to share?';

  @override
  String get createPostAttachImage => 'Add photo';

  @override
  String get createPostRemoveImage => 'Remove photo';

  @override
  String get createPostPollToggle => 'Add a poll';

  @override
  String get createPostBoostToggle => 'Boost post (×3 cost, 24h)';

  @override
  String createPostPollOptionHint(int n) {
    return 'Option $n';
  }

  @override
  String get createPostAddPollOption => 'Add option';

  @override
  String get createPostSubmit => 'Publish';

  @override
  String createPostCost(int credits) {
    return 'Cost: $credits credits';
  }

  @override
  String get createPostValidationNeedBody => 'Add some text or a photo.';

  @override
  String get createPostValidationPoll => 'Enter at least two poll options.';

  @override
  String get createPostSuccessPublished => 'Your post is live.';

  @override
  String get createPostSuccessReview => 'Post sent for review.';

  @override
  String get createPostErrorGeneric => 'Could not create the post.';

  @override
  String get socialCreatePost => 'Create post';

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
  String get dailyTodaysPulse => 'Today\'s Pulse';

  @override
  String get dailyPreviousPulses => 'Previous Pulses';

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
  String get dailyAppBarRankPrefix => 'Rank:';

  @override
  String get dailyAppBarNotificationsTooltip => 'Notifications';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String get profileNetWorthLabel => 'NET WORTH';

  @override
  String get profileVerifiedNetWorthLabel => 'VERIFIED NET WORTH';

  @override
  String get profileStatRank => 'RANK';

  @override
  String get profileStatFollowers => 'FOLLOWERS';

  @override
  String get profileStatPosts => 'POSTS';

  @override
  String get rankTierStarter => 'Starter';

  @override
  String get rankTierBuilder => 'Builder';

  @override
  String get rankTierScaler => 'Scaler';

  @override
  String get rankTierElite => 'Elite';

  @override
  String get rankTierWhale => 'Whale';

  @override
  String get settingsAccountSectionTitle => 'Account settings';

  @override
  String get settingsPersonalInformationTitle => 'Personal Information';

  @override
  String get settingsPersonalInformationSubtitle =>
      'Update your profile details';

  @override
  String get settingsPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Control your visibility';

  @override
  String get settingsTermsOfUseTitle => 'Terms of Use';

  @override
  String get settingsTermsOfUseSubtitle => 'Legal agreements';

  @override
  String get settingsDeleteAccountTitle => 'Delete Account';

  @override
  String get settingsDeleteAccountSubtitle => 'Permanently remove your data';

  @override
  String get settingsBrandFooter => 'NETWORLD';

  @override
  String get settingsCouldNotOpenLink => 'Could not open link';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsAppLanguageTitle => 'App language';

  @override
  String get settingsAppLanguageCardTitle => 'App language';

  @override
  String get settingsAppLanguageCardSubtitle => 'Choose display language';

  @override
  String get settingsLanguageFrenchLabel => 'Français';

  @override
  String get settingsLanguageEnglishLabel => 'English';

  @override
  String get editProfileDescription =>
      'You can update how others see your name on Networld.';

  @override
  String get editProfileUsernameLabel => 'Username';

  @override
  String get editProfileUsernameHint => 'Enter your username';

  @override
  String get editProfileSaveChanges => 'Save changes';

  @override
  String get deleteAccountWarningTitle => 'This action is permanent';

  @override
  String get deleteAccountWarningBody =>
      'Deleting your account will permanently remove your profile, content and progress from Networld.';

  @override
  String get deleteAccountDialogTitle => 'Delete account?';

  @override
  String get deleteAccountDialogMessage =>
      'This cannot be undone. Your profile and data will be removed.';

  @override
  String get deleteAccountDialogConfirm => 'Delete forever';

  @override
  String get deleteAccountDialogAbort => 'Not now';

  @override
  String get deleteAccountConfirm => 'Delete account permanently';

  @override
  String get deleteAccountCancel => 'Cancel';

  @override
  String get profileUsernameRequired => 'Username is required';

  @override
  String get profileUsernameMinLength => 'Use at least 3 characters';

  @override
  String get profileUsernameMaxLength => 'Use at most 30 characters';

  @override
  String get profileUsernameInvalidChars =>
      'Only letters, numbers and underscores';

  @override
  String get profileUpdatedMessage => 'Profile updated';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
