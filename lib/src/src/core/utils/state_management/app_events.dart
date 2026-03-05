import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../locale/l10n.dart';
import '../../providers/widgets/snackbar_provider.dart';
import 'mixins.dart';
import 'single_events.dart';

final appEventProvider = Provider((ref) => AppEvents());

class AppEvents with SingleEventMixin {
	AppEvents() : super();
}

final appEventsListenerProvider = Provider<void>((ref) {
  final events = ref.read(appEventProvider);

  final sub = events.singleEvents.listen((event) {
    final snackbar = ref.read(snackbarProvider);

    if (event is ShowErrorEvent) {
      snackbar.showError(event.message(
        ref.read(l10nProvider)
      ));
    } else if (event is ShowSuccessMessageEvent) {
      snackbar.showSuccess(event.message);
    } else if (event is ShowInfoMessageEvent) {
      snackbar.showInfo(event.message);
    }
  });

  ref.onDispose(sub.cancel);
});
