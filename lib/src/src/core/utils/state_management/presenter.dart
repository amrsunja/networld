import 'package:hooks_riverpod/legacy.dart';

import 'mixins.dart';

class Presenter<S> extends StateNotifier<S> {
  Presenter(super.state);

  @override
  bool updateShouldNotify(S old, S current) => old != current;
}

class EventPresenter<S, E> extends StateNotifier<S> with SingleEventMixin<E> {
  EventPresenter(super.state);

  @override
  bool updateShouldNotify(S old, S current) => old != current;

	@override
	void dispose() {
		closeStreamController();
		super.dispose();
	}
}
