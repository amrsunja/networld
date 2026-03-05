import '../../errors/failures/failures.dart';
import '../../locale/l10n.dart';

abstract class SingleEvent {
  const SingleEvent();
}

class ShowSuccessMessageEvent extends SingleEvent {
  final String message;

  const ShowSuccessMessageEvent(this.message);
}

class ShowInfoMessageEvent extends SingleEvent {
  final String message;

  const ShowInfoMessageEvent(this.message);
}

class ShowErrorEvent extends SingleEvent {
  final Failure? error;
  final String defaultMessage;

  const ShowErrorEvent(this.error, {this.defaultMessage = ''});

  String message(AppLocale locale) =>
      error?.toMessage(locale) ?? defaultMessage;
}

// Navigation EVENTS -----------------
class NavigateRouteEvent extends SingleEvent {
  final String routePath;
  const NavigateRouteEvent(this.routePath);
}

class PushRouteEvent extends SingleEvent {
  final String routePath;
  const PushRouteEvent(this.routePath);
}

class ReplaceRouteEvent extends SingleEvent {
  final String routePath;
  const ReplaceRouteEvent(this.routePath);
}
