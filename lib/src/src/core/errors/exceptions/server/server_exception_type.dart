import 'package:flutter/material.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';

enum ServerExceptionType {
  unauthorized,
  insufficientCredits,
  netWorthRequired,
  manualAmountLimitUsePowens,
  powensCreateSessionFailed,
  powensPermanentTokenRequired,
  profileNotFound,
  alreadyClaimedToday,
  missionNotFound,
  invalidPostType,
  pollRequiresTwoOptions,
  unknown;

  static ServerExceptionType fromString(String? code) {
    return switch (code) {
      'unauthorized'                      => ServerExceptionType.unauthorized,
      'insufficient_credits'              => ServerExceptionType.insufficientCredits,
      'net_worth_required'                => ServerExceptionType.netWorthRequired,
      'manual_amount_limit_use_powens'    => ServerExceptionType.manualAmountLimitUsePowens,
      'powens_permanent_token_required'   => ServerExceptionType.powensPermanentTokenRequired,
      'powens_create_session_failed'      => ServerExceptionType.powensCreateSessionFailed,
      'profile_not_found'                 => ServerExceptionType.profileNotFound,
      'already_claimed_today'             => ServerExceptionType.alreadyClaimedToday,
      'mission_not_found'                 => ServerExceptionType.missionNotFound,
      'invalid_post_type'                 => ServerExceptionType.invalidPostType,
      'poll_requires_at_least_2_options'  => ServerExceptionType.pollRequiresTwoOptions,
      'ref_id_required_for_mission'       => ServerExceptionType.unknown,
      _                                   => ServerExceptionType.unknown,
    };
  }

  String message(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return messageWith(l10n);
  }

  String messageWith(AppLocalizations l10n) {
    return switch (this) {
      ServerExceptionType.unauthorized                  => l10n.errorUnauthorized,
      ServerExceptionType.insufficientCredits           => l10n.errorInsufficientCredits,
      ServerExceptionType.netWorthRequired              => l10n.errorNetWorthRequired,
      ServerExceptionType.manualAmountLimitUsePowens    => l10n.errorManualLimitUsePowens,
      ServerExceptionType.powensCreateSessionFailed     => l10n.errorPowensSession,
      ServerExceptionType.powensPermanentTokenRequired  => l10n.errorPowensPermanentTokenRequired,
      ServerExceptionType.profileNotFound               => l10n.errorProfileNotFound,
      ServerExceptionType.alreadyClaimedToday           => l10n.errorAlreadyClaimedToday,
      ServerExceptionType.missionNotFound               => l10n.errorMissionNotFound,
      ServerExceptionType.invalidPostType               => l10n.errorInvalidPostType,
      ServerExceptionType.pollRequiresTwoOptions        => l10n.errorPollRequiresTwoOptions,
      ServerExceptionType.unknown                       => l10n.errorUnknown,
    };
  }
}
