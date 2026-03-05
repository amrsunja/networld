import 'package:flutter/material.dart';
import 'package:hooks_riverpod/legacy.dart';

final scaffoldMessengerProvider = StateProvider<GlobalKey<ScaffoldMessengerState>>(
  (_) => GlobalKey<ScaffoldMessengerState>()
);

