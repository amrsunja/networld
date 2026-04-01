import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appLanguage.
  ///
  /// In fr, this message translates to:
  /// **'French'**
  String get appLanguage;

  /// No description provided for @l10nSuccess.
  ///
  /// In fr, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUCCESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nSuccess;

  /// No description provided for @success_internet_connection.
  ///
  /// In fr, this message translates to:
  /// **'Internet connection established'**
  String get success_internet_connection;

  /// No description provided for @l10nErrors.
  ///
  /// In fr, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nErrors;

  /// No description provided for @error_server_failure.
  ///
  /// In fr, this message translates to:
  /// **'Something went wrong. Please check your internet connection'**
  String get error_server_failure;

  /// No description provided for @error_db_failure.
  ///
  /// In fr, this message translates to:
  /// **'Something went wrong. Please try again or contact us'**
  String get error_db_failure;

  /// No description provided for @error_internet_connection_lost.
  ///
  /// In fr, this message translates to:
  /// **'Internet connection is lost'**
  String get error_internet_connection_lost;

  /// No description provided for @errorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'êtes pas autorisé. Veuillez vous reconnecter.'**
  String get errorUnauthorized;

  /// No description provided for @errorInsufficientCredits.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas assez de crédits pour effectuer cette action.'**
  String get errorInsufficientCredits;

  /// No description provided for @errorNetWorthRequired.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'indiquer votre patrimoine pour continuer.'**
  String get errorNetWorthRequired;

  /// No description provided for @errorManualLimitUsePowens.
  ///
  /// In fr, this message translates to:
  /// **'La saisie manuelle est limitée à 25 000 €. Connectez votre banque avec Powens pour aller plus loin.'**
  String get errorManualLimitUsePowens;

  /// No description provided for @errorPowensSession.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de démarrer la session sécurisée Powens. Veuillez réessayer.'**
  String get errorPowensSession;

  /// No description provided for @errorPowensPermanentTokenRequired.
  ///
  /// In fr, this message translates to:
  /// **'Votre connexion bancaire a expiré. Veuillez reconnecter votre banque avec Powens.'**
  String get errorPowensPermanentTokenRequired;

  /// No description provided for @errorProfileNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Nous n\'avons pas trouvé votre profil. Veuillez réessayer.'**
  String get errorProfileNotFound;

  /// No description provided for @errorAlreadyClaimedToday.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà réclamé cette récompense aujourd\'hui.'**
  String get errorAlreadyClaimedToday;

  /// No description provided for @errorMissionNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette mission n\'est plus disponible.'**
  String get errorMissionNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inconnue s\'est produite. Veuillez réessayer.'**
  String get errorUnknown;

  /// No description provided for @errorInvalidPostType.
  ///
  /// In fr, this message translates to:
  /// **'Ce type de publication n\'est pas valide.'**
  String get errorInvalidPostType;

  /// No description provided for @errorPollRequiresTwoOptions.
  ///
  /// In fr, this message translates to:
  /// **'Un sondage nécessite au moins deux options.'**
  String get errorPollRequiresTwoOptions;

  /// No description provided for @createPostTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle publication'**
  String get createPostTitle;

  /// No description provided for @createPostHint.
  ///
  /// In fr, this message translates to:
  /// **'Que voulez-vous partager ?'**
  String get createPostHint;

  /// No description provided for @createPostAttachImage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get createPostAttachImage;

  /// No description provided for @createPostRemoveImage.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get createPostRemoveImage;

  /// No description provided for @createPostPollToggle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un sondage'**
  String get createPostPollToggle;

  /// No description provided for @createPostBoostToggle.
  ///
  /// In fr, this message translates to:
  /// **'Booster la publication (coût ×3, 24h)'**
  String get createPostBoostToggle;

  /// No description provided for @createPostPollOptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Option {n}'**
  String createPostPollOptionHint(int n);

  /// No description provided for @createPostAddPollOption.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une option'**
  String get createPostAddPollOption;

  /// No description provided for @createPostSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get createPostSubmit;

  /// No description provided for @createPostCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût : {credits} crédits'**
  String createPostCost(int credits);

  /// No description provided for @createPostValidationNeedBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez du texte ou une photo.'**
  String get createPostValidationNeedBody;

  /// No description provided for @createPostValidationPoll.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez au moins deux options de sondage.'**
  String get createPostValidationPoll;

  /// No description provided for @createPostSuccessPublished.
  ///
  /// In fr, this message translates to:
  /// **'Votre publication est en ligne.'**
  String get createPostSuccessPublished;

  /// No description provided for @createPostSuccessReview.
  ///
  /// In fr, this message translates to:
  /// **'Publication envoyée en modération.'**
  String get createPostSuccessReview;

  /// No description provided for @createPostErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer la publication.'**
  String get createPostErrorGeneric;

  /// No description provided for @socialCreatePost.
  ///
  /// In fr, this message translates to:
  /// **'Créer une publication'**
  String get socialCreatePost;

  /// No description provided for @dailySurveyOfTheDay.
  ///
  /// In fr, this message translates to:
  /// **'Sondage du jour'**
  String get dailySurveyOfTheDay;

  /// No description provided for @dailySurveyGiftClaimed.
  ///
  /// In fr, this message translates to:
  /// **'Récompense du jour réclamée'**
  String get dailySurveyGiftClaimed;

  /// No description provided for @dailyClaim.
  ///
  /// In fr, this message translates to:
  /// **'Claim'**
  String get dailyClaim;

  /// No description provided for @dailyClaimed.
  ///
  /// In fr, this message translates to:
  /// **'Réclamé ✓'**
  String get dailyClaimed;

  /// No description provided for @dailyVoteFirst.
  ///
  /// In fr, this message translates to:
  /// **'Vote d\'abord'**
  String get dailyVoteFirst;

  /// No description provided for @dailyTodaysPulse.
  ///
  /// In fr, this message translates to:
  /// **'Pulse du jour'**
  String get dailyTodaysPulse;

  /// No description provided for @dailyPreviousPulses.
  ///
  /// In fr, this message translates to:
  /// **'Pulses précédents'**
  String get dailyPreviousPulses;

  /// No description provided for @dailyMissions.
  ///
  /// In fr, this message translates to:
  /// **'Daily Missions'**
  String get dailyMissions;

  /// No description provided for @dailyCollect.
  ///
  /// In fr, this message translates to:
  /// **'Collect'**
  String get dailyCollect;

  /// No description provided for @dailyOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get dailyOpenLink;

  /// No description provided for @dailyMissionStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get dailyMissionStart;

  /// No description provided for @dailyInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours...'**
  String get dailyInProgress;

  /// No description provided for @dailyCreditsAdded.
  ///
  /// In fr, this message translates to:
  /// **'+{count} crédits ajoutés !'**
  String dailyCreditsAdded(int count);

  /// No description provided for @dailyAppBarRankPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Rang :'**
  String get dailyAppBarRankPrefix;

  /// No description provided for @dailyAppBarNotificationsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get dailyAppBarNotificationsTooltip;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Profil indisponible'**
  String get profileUnavailable;

  /// No description provided for @profileNetWorthLabel.
  ///
  /// In fr, this message translates to:
  /// **'PATRIMOINE NET'**
  String get profileNetWorthLabel;

  /// No description provided for @profileVerifiedNetWorthLabel.
  ///
  /// In fr, this message translates to:
  /// **'PATRIMOINE NET VÉRIFIÉ'**
  String get profileVerifiedNetWorthLabel;

  /// No description provided for @profileStatRank.
  ///
  /// In fr, this message translates to:
  /// **'RANG'**
  String get profileStatRank;

  /// No description provided for @profileStatFollowers.
  ///
  /// In fr, this message translates to:
  /// **'ABONNÉS'**
  String get profileStatFollowers;

  /// No description provided for @profileStatPosts.
  ///
  /// In fr, this message translates to:
  /// **'PUBLICATIONS'**
  String get profileStatPosts;

  /// No description provided for @rankTierStarter.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get rankTierStarter;

  /// No description provided for @rankTierBuilder.
  ///
  /// In fr, this message translates to:
  /// **'Bâtisseur'**
  String get rankTierBuilder;

  /// No description provided for @rankTierScaler.
  ///
  /// In fr, this message translates to:
  /// **'Accélérateur'**
  String get rankTierScaler;

  /// No description provided for @rankTierElite.
  ///
  /// In fr, this message translates to:
  /// **'Élite'**
  String get rankTierElite;

  /// No description provided for @rankTierWhale.
  ///
  /// In fr, this message translates to:
  /// **'Baleine'**
  String get rankTierWhale;

  /// No description provided for @settingsAccountSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres du compte'**
  String get settingsAccountSectionTitle;

  /// No description provided for @settingsPersonalInformationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get settingsPersonalInformationTitle;

  /// No description provided for @settingsPersonalInformationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour les détails du profil'**
  String get settingsPersonalInformationSubtitle;

  /// No description provided for @settingsPrivacyPolicyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicyTitle;

  /// No description provided for @settingsPrivacyPolicySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôler votre visibilité'**
  String get settingsPrivacyPolicySubtitle;

  /// No description provided for @settingsTermsOfUseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTermsOfUseTitle;

  /// No description provided for @settingsTermsOfUseSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accords juridiques'**
  String get settingsTermsOfUseSubtitle;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement vos données'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsBrandFooter.
  ///
  /// In fr, this message translates to:
  /// **'NETWORLD'**
  String get settingsBrandFooter;

  /// No description provided for @settingsCouldNotOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le lien'**
  String get settingsCouldNotOpenLink;

  /// No description provided for @settingsLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get settingsLogout;

  /// No description provided for @settingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTooltip;

  /// No description provided for @settingsAppLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get settingsAppLanguageTitle;

  /// No description provided for @settingsAppLanguageCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get settingsAppLanguageCardTitle;

  /// No description provided for @settingsAppLanguageCardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue d\'affichage'**
  String get settingsAppLanguageCardSubtitle;

  /// No description provided for @settingsLanguageFrenchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrenchLabel;

  /// No description provided for @settingsLanguageEnglishLabel.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get settingsLanguageEnglishLabel;

  /// No description provided for @editProfileDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez modifier la façon dont les autres vous voient sur Networld.'**
  String get editProfileDescription;

  /// No description provided for @editProfileUsernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get editProfileUsernameLabel;

  /// No description provided for @editProfileUsernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre nom d\'utilisateur'**
  String get editProfileUsernameHint;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get editProfileSaveChanges;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningBody.
  ///
  /// In fr, this message translates to:
  /// **'La suppression de votre compte effacera définitivement votre profil, votre contenu et votre progression sur Networld.'**
  String get deleteAccountWarningBody;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Votre profil et vos données seront supprimés.'**
  String get deleteAccountDialogMessage;

  /// No description provided for @deleteAccountDialogConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteAccountDialogConfirm;

  /// No description provided for @deleteAccountDialogAbort.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get deleteAccountDialogAbort;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement le compte'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get deleteAccountCancel;

  /// No description provided for @profileUsernameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom d\'utilisateur est obligatoire'**
  String get profileUsernameRequired;

  /// No description provided for @profileUsernameMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 3 caractères'**
  String get profileUsernameMinLength;

  /// No description provided for @profileUsernameMaxLength.
  ///
  /// In fr, this message translates to:
  /// **'Au plus 30 caractères'**
  String get profileUsernameMaxLength;

  /// No description provided for @profileUsernameInvalidChars.
  ///
  /// In fr, this message translates to:
  /// **'Lettres, chiffres et tirets bas uniquement'**
  String get profileUsernameInvalidChars;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileUpdatedMessage;

  /// No description provided for @profilePostsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication pour l\'instant'**
  String get profilePostsEmpty;

  /// No description provided for @profileReportAction.
  ///
  /// In fr, this message translates to:
  /// **'Signaler ce profil'**
  String get profileReportAction;

  /// No description provided for @socialFeedRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get socialFeedRetry;

  /// No description provided for @socialFeedEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication pour l\'instant'**
  String get socialFeedEmpty;

  /// No description provided for @socialPostShareLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié'**
  String get socialPostShareLinkCopied;

  /// No description provided for @socialPostTypePoll.
  ///
  /// In fr, this message translates to:
  /// **'Sondage'**
  String get socialPostTypePoll;

  /// No description provided for @socialPostTypePost.
  ///
  /// In fr, this message translates to:
  /// **'Publication'**
  String get socialPostTypePost;

  /// No description provided for @socialPostBoostBadge.
  ///
  /// In fr, this message translates to:
  /// **'BOOST'**
  String get socialPostBoostBadge;

  /// No description provided for @socialAuthorPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get socialAuthorPlaceholder;

  /// No description provided for @socialRelativeCommentSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{count}s'**
  String socialRelativeCommentSeconds(int count);

  /// No description provided for @socialRelativeCommentMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{count}min'**
  String socialRelativeCommentMinutes(int count);

  /// No description provided for @socialRelativeCommentHours.
  ///
  /// In fr, this message translates to:
  /// **'{count}h'**
  String socialRelativeCommentHours(int count);

  /// No description provided for @socialRelativeCommentDays.
  ///
  /// In fr, this message translates to:
  /// **'{count}j'**
  String socialRelativeCommentDays(int count);

  /// No description provided for @socialRelativeFeedSecondsAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}s'**
  String socialRelativeFeedSecondsAgo(int count);

  /// No description provided for @socialRelativeFeedMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}min'**
  String socialRelativeFeedMinutesAgo(int count);

  /// No description provided for @socialRelativeFeedHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}h'**
  String socialRelativeFeedHoursAgo(int count);

  /// No description provided for @socialRelativeFeedDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}j'**
  String socialRelativeFeedDaysAgo(int count);

  /// No description provided for @socialRelativeFeedDate.
  ///
  /// In fr, this message translates to:
  /// **'{day}/{month}/{year}'**
  String socialRelativeFeedDate(int day, int month, int year);

  /// No description provided for @socialCommentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get socialCommentsTitle;

  /// No description provided for @socialCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un commentaire…'**
  String get socialCommentHint;

  /// No description provided for @socialCommentReplyingToPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Réponse à @'**
  String get socialCommentReplyingToPrefix;

  /// No description provided for @socialCommentReplyAction.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get socialCommentReplyAction;

  /// No description provided for @socialActionReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get socialActionReport;

  /// No description provided for @socialActionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get socialActionDelete;

  /// No description provided for @socialDeleteCommentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le commentaire ?'**
  String get socialDeleteCommentTitle;

  /// No description provided for @socialDeletePostTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la publication ?'**
  String get socialDeletePostTitle;

  /// No description provided for @socialDeleteCannotUndoBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get socialDeleteCannotUndoBody;

  /// No description provided for @socialReportCategorySpam.
  ///
  /// In fr, this message translates to:
  /// **'Spam'**
  String get socialReportCategorySpam;

  /// No description provided for @socialReportCategoryHarassment.
  ///
  /// In fr, this message translates to:
  /// **'Harcèlement'**
  String get socialReportCategoryHarassment;

  /// No description provided for @socialReportCategoryInappropriate.
  ///
  /// In fr, this message translates to:
  /// **'Contenu inapproprié'**
  String get socialReportCategoryInappropriate;

  /// No description provided for @socialReportCategoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get socialReportCategoryOther;

  /// No description provided for @socialSnackbarReportSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé'**
  String get socialSnackbarReportSubmitted;

  /// No description provided for @socialSnackbarCommentDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire supprimé'**
  String get socialSnackbarCommentDeleted;

  /// No description provided for @socialSnackbarPostDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Publication supprimée'**
  String get socialSnackbarPostDeleted;

  /// No description provided for @avatarsPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avatars'**
  String get avatarsPageTitle;

  /// No description provided for @avatarsCollectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Collection'**
  String get avatarsCollectionTitle;

  /// No description provided for @avatarsCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'AVATAR ACTUEL'**
  String get avatarsCurrentLabel;

  /// No description provided for @avatarsResetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get avatarsResetButton;

  /// No description provided for @avatarsSelectedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionné'**
  String get avatarsSelectedLabel;

  /// No description provided for @avatarsSelectButton.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get avatarsSelectButton;

  /// No description provided for @avatarsBuyButton.
  ///
  /// In fr, this message translates to:
  /// **'Acheter'**
  String get avatarsBuyButton;

  /// No description provided for @avatarsGetFreeButton.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir'**
  String get avatarsGetFreeButton;

  /// No description provided for @errorAvatarNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Avatar introuvable.'**
  String get errorAvatarNotFound;

  /// No description provided for @errorAlreadyOwned.
  ///
  /// In fr, this message translates to:
  /// **'Vous possédez déjà cet avatar.'**
  String get errorAlreadyOwned;

  /// No description provided for @l10nStopLineDontTouch.
  ///
  /// In fr, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nStopLineDontTouch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
