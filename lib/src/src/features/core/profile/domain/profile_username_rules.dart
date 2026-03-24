import 'package:networld/src/src/core/locale/gen/app_localizations.dart';

/// Client-side rules for editable profile username.
String? validateProfileUsername(String raw, AppLocalizations l10n) {
  final value = raw.trim();
  if (value.isEmpty) {
    return l10n.profileUsernameRequired;
  }
  if (value.length < 3) {
    return l10n.profileUsernameMinLength;
  }
  if (value.length > 30) {
    return l10n.profileUsernameMaxLength;
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return l10n.profileUsernameInvalidChars;
  }
  return null;
}
