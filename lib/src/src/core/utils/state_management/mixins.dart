import 'dart:async';

mixin SingleEventMixin<E> {
  final _singleEventsController = StreamController<E>.broadcast();

  void closeStreamController() => _singleEventsController.close();

  Stream<E> get singleEvents => _singleEventsController.stream;

  void send(E event) {
    _singleEventsController.add(event);
  }
}
