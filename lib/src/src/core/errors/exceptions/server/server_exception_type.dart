import 'package:flutter/material.dart';
import 'package:networld/src/src/core/locale/l10n.dart';

enum ServerExceptionType {
  unauthorized,
  insufficientCredits,
  netWorthRequired,
  manualAmountLimitUsePowens,
  powensCreateSessionFailed,
  powensPermanentTokenRequired,
  profileNotFound,
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
      _                                   => ServerExceptionType.unknown,
    };
  }

  String message(BuildContext context) {
    final l10n = AppLocale.of(context); // ton système i18n
    return switch (this) {
      ServerExceptionType.unauthorized                  => l10n.errorUnauthorized,
      ServerExceptionType.insufficientCredits           => l10n.errorInsufficientCredits,
      ServerExceptionType.netWorthRequired              => l10n.errorNetWorthRequired,
      ServerExceptionType.manualAmountLimitUsePowens    => l10n.errorManualLimitUsePowens,
      ServerExceptionType.powensCreateSessionFailed     => l10n.errorPowensSession,
      ServerExceptionType.powensPermanentTokenRequired  => l10n.errorPowensPermanentTokenRequired,
      ServerExceptionType.profileNotFound               => l10n.errorProfileNotFound,
      ServerExceptionType.unknown                       => l10n.errorUnknown,
      _                                                 => l10n.errorUnknown,
    };
  }
}
