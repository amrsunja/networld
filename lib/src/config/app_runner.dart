
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../src/app.dart';

/// To run app									- .runApplication
abstract class AppRunner {
	static void runApplication() => _run(const App());

	static void _run(Widget child) => runApp(ProviderScope(child: child));
}
