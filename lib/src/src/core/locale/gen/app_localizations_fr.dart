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
  String get errorInvalidPostType =>
      'Ce type de publication n\'est pas valide.';

  @override
  String get errorPollRequiresTwoOptions =>
      'Un sondage nécessite au moins deux options.';

  @override
  String get createPostTitle => 'Nouvelle publication';

  @override
  String get createPostHint => 'Que voulez-vous partager ?';

  @override
  String get createPostAttachImage => 'Ajouter une photo';

  @override
  String get createPostRemoveImage => 'Retirer la photo';

  @override
  String get createPostPollToggle => 'Ajouter un sondage';

  @override
  String get createPostBoostToggle => 'Booster la publication (coût ×3, 24h)';

  @override
  String createPostPollOptionHint(int n) {
    return 'Option $n';
  }

  @override
  String get createPostAddPollOption => 'Ajouter une option';

  @override
  String get createPostSubmit => 'Publier';

  @override
  String createPostCost(int credits) {
    return 'Coût : $credits crédits';
  }

  @override
  String get createPostValidationNeedBody => 'Ajoutez du texte ou une photo.';

  @override
  String get createPostValidationPoll =>
      'Saisissez au moins deux options de sondage.';

  @override
  String get createPostSuccessPublished => 'Votre publication est en ligne.';

  @override
  String get createPostSuccessReview => 'Publication envoyée en modération.';

  @override
  String get createPostErrorGeneric => 'Impossible de créer la publication.';

  @override
  String get socialCreatePost => 'Créer une publication';

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
  String get dailyTodaysPulse => 'Pulse du jour';

  @override
  String get dailyPreviousPulses => 'Pulses précédents';

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
  String get dailyAppBarRankPrefix => 'Rang :';

  @override
  String get dailyAppBarNotificationsTooltip => 'Notifications';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileUnavailable => 'Profil indisponible';

  @override
  String get profileNetWorthLabel => 'PATRIMOINE NET';

  @override
  String get profileVerifiedNetWorthLabel => 'PATRIMOINE NET VÉRIFIÉ';

  @override
  String get profileStatRank => 'RANG';

  @override
  String get profileStatFollowers => 'ABONNÉS';

  @override
  String get profileStatFollowing => 'ABONNEMENTS';

  @override
  String get profileStatPosts => 'PUBLICATIONS';

  @override
  String get profileFollowAction => 'S\'abonner';

  @override
  String get profileUnfollowAction => 'Abonné';

  @override
  String get profileFollowersEmpty => 'Aucun abonné pour l\'instant';

  @override
  String get profileFollowingEmpty => 'Aucun abonnement pour l\'instant';

  @override
  String get rankTierStarter => 'Débutant';

  @override
  String get rankTierBuilder => 'Bâtisseur';

  @override
  String get rankTierScaler => 'Accélérateur';

  @override
  String get rankTierElite => 'Élite';

  @override
  String get rankTierWhale => 'Baleine';

  @override
  String get settingsAccountSectionTitle => 'Paramètres du compte';

  @override
  String get settingsPersonalInformationTitle => 'Informations personnelles';

  @override
  String get settingsPersonalInformationSubtitle =>
      'Mettre à jour les détails du profil';

  @override
  String get settingsPrivacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicySubtitle => 'Contrôler votre visibilité';

  @override
  String get settingsTermsOfUseTitle => 'Conditions d\'utilisation';

  @override
  String get settingsTermsOfUseSubtitle => 'Accords juridiques';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Supprimer définitivement vos données';

  @override
  String get settingsBrandFooter => 'NETWORLD';

  @override
  String get settingsCouldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get settingsLogout => 'Déconnexion';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get settingsAppLanguageTitle => 'Langue de l\'application';

  @override
  String get settingsAppLanguageCardTitle => 'Langue de l\'application';

  @override
  String get settingsAppLanguageCardSubtitle =>
      'Choisir la langue d\'affichage';

  @override
  String get settingsLanguageFrenchLabel => 'Français';

  @override
  String get settingsLanguageEnglishLabel => 'Anglais';

  @override
  String get editProfileDescription =>
      'Vous pouvez modifier la façon dont les autres vous voient sur Networld.';

  @override
  String get editProfileUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get editProfileUsernameHint => 'Saisissez votre nom d\'utilisateur';

  @override
  String get editProfileSaveChanges => 'Enregistrer';

  @override
  String get deleteAccountWarningTitle => 'Cette action est irréversible';

  @override
  String get deleteAccountWarningBody =>
      'La suppression de votre compte effacera définitivement votre profil, votre contenu et votre progression sur Networld.';

  @override
  String get deleteAccountDialogTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountDialogMessage =>
      'Cette action est irréversible. Votre profil et vos données seront supprimés.';

  @override
  String get deleteAccountDialogConfirm => 'Supprimer définitivement';

  @override
  String get deleteAccountDialogAbort => 'Pas maintenant';

  @override
  String get deleteAccountConfirm => 'Supprimer définitivement le compte';

  @override
  String get deleteAccountCancel => 'Annuler';

  @override
  String get profileUsernameRequired => 'Le nom d\'utilisateur est obligatoire';

  @override
  String get profileUsernameMinLength => 'Au moins 3 caractères';

  @override
  String get profileUsernameMaxLength => 'Au plus 30 caractères';

  @override
  String get profileUsernameInvalidChars =>
      'Lettres, chiffres et tirets bas uniquement';

  @override
  String get profileUpdatedMessage => 'Profil mis à jour';

  @override
  String get profilePostsEmpty => 'Aucune publication pour l\'instant';

  @override
  String get profileReportAction => 'Signaler ce profil';

  @override
  String get socialFeedRetry => 'Réessayer';

  @override
  String get socialFeedEmpty => 'Aucune publication pour l\'instant';

  @override
  String get socialPostShareLinkCopied => 'Lien copié';

  @override
  String get socialPostTypePoll => 'Sondage';

  @override
  String get socialPostTypePost => 'Publication';

  @override
  String get socialPostBoostBadge => 'BOOST';

  @override
  String get socialAuthorPlaceholder => '—';

  @override
  String socialRelativeCommentSeconds(int count) {
    return '${count}s';
  }

  @override
  String socialRelativeCommentMinutes(int count) {
    return '${count}min';
  }

  @override
  String socialRelativeCommentHours(int count) {
    return '${count}h';
  }

  @override
  String socialRelativeCommentDays(int count) {
    return '${count}j';
  }

  @override
  String socialRelativeFeedSecondsAgo(int count) {
    return 'il y a ${count}s';
  }

  @override
  String socialRelativeFeedMinutesAgo(int count) {
    return 'il y a ${count}min';
  }

  @override
  String socialRelativeFeedHoursAgo(int count) {
    return 'il y a ${count}h';
  }

  @override
  String socialRelativeFeedDaysAgo(int count) {
    return 'il y a ${count}j';
  }

  @override
  String socialRelativeFeedDate(int day, int month, int year) {
    return '$day/$month/$year';
  }

  @override
  String get socialCommentsTitle => 'Commentaires';

  @override
  String get socialCommentHint => 'Écrire un commentaire…';

  @override
  String get socialCommentReplyingToPrefix => 'Réponse à @';

  @override
  String get socialCommentReplyAction => 'Répondre';

  @override
  String get socialActionReport => 'Signaler';

  @override
  String get socialActionDelete => 'Supprimer';

  @override
  String get socialDeleteCommentTitle => 'Supprimer le commentaire ?';

  @override
  String get socialDeletePostTitle => 'Supprimer la publication ?';

  @override
  String get socialDeleteCannotUndoBody => 'Cette action est irréversible.';

  @override
  String get socialReportCategorySpam => 'Spam';

  @override
  String get socialReportCategoryHarassment => 'Harcèlement';

  @override
  String get socialReportCategoryInappropriate => 'Contenu inapproprié';

  @override
  String get socialReportCategoryOther => 'Autre';

  @override
  String get socialSnackbarReportSubmitted => 'Signalement envoyé';

  @override
  String get socialSnackbarCommentDeleted => 'Commentaire supprimé';

  @override
  String get socialSnackbarPostDeleted => 'Publication supprimée';

  @override
  String get avatarsPageTitle => 'Avatars';

  @override
  String get avatarsCollectionTitle => 'Collection';

  @override
  String get avatarsCurrentLabel => 'AVATAR ACTUEL';

  @override
  String get avatarsResetButton => 'Réinitialiser';

  @override
  String get avatarsSelectedLabel => 'Sélectionné';

  @override
  String get avatarsSelectButton => 'Choisir';

  @override
  String get avatarsBuyButton => 'Acheter';

  @override
  String get avatarsGetFreeButton => 'Obtenir';

  @override
  String get errorAvatarNotFound => 'Avatar introuvable.';

  @override
  String get errorAlreadyOwned => 'Vous possédez déjà cet avatar.';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
