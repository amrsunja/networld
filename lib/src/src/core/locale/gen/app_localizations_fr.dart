// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appLanguage => 'French';

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
      'Vous n\'êtes pas autorisé. Veuillez vous reconnecter.';

  @override
  String get errorInsufficientCredits =>
      'Vous n\'avez pas assez de crédits pour effectuer cette action.';

  @override
  String get errorNetWorthRequired =>
      'Merci d\'indiquer votre patrimoine pour continuer.';

  @override
  String get errorManualLimitUsePowens =>
      'La saisie manuelle est limitée à 25 000 €. Connectez votre banque avec Powens pour aller plus loin.';

  @override
  String get errorPowensSession =>
      'Impossible de démarrer la session sécurisée Powens. Veuillez réessayer.';

  @override
  String get errorPowensPermanentTokenRequired =>
      'Votre connexion bancaire a expiré. Veuillez reconnecter votre banque avec Powens.';

  @override
  String get errorProfileNotFound =>
      'Nous n\'avons pas trouvé votre profil. Veuillez réessayer.';

  @override
  String get errorAlreadyClaimedToday =>
      'Tu as déjà réclamé cette récompense aujourd\'hui.';

  @override
  String get errorMissionNotFound => 'Cette mission n\'est plus disponible.';

  @override
  String get errorUnknown =>
      'Une erreur inconnue s\'est produite. Veuillez réessayer.';

  @override
  String get dailySurveyOfTheDay => 'Sondage du jour';

  @override
  String get dailySurveyGiftClaimed => 'Récompense du jour réclamée';

  @override
  String get dailyClaim => 'Claim';

  @override
  String get dailyClaimed => 'Réclamé ✓';

  @override
  String get dailyVoteFirst => 'Vote d\'abord';

  @override
  String get dailyMissions => 'Daily Missions';

  @override
  String get dailyCollect => 'Collect';

  @override
  String get dailyOpenLink => 'Ouvrir';

  @override
  String get dailyMissionStart => 'Commencer';

  @override
  String get dailyInProgress => 'En cours...';

  @override
  String dailyCreditsAdded(int count) {
    return '+$count crédits ajoutés !';
  }

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
