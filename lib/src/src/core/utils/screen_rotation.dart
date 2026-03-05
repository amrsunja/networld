import 'package:flutter/services.dart';

abstract class ScreenRotation {
	static void toPortrait() {
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.portraitUp,
			DeviceOrientation.portraitDown,
		]);
	}

	static void toLandscape() {
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.landscapeRight,
			DeviceOrientation.landscapeLeft,
		]);
	}

	static void toDynamic() {
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.landscapeRight,
			DeviceOrientation.landscapeLeft,
			DeviceOrientation.portraitUp,
			DeviceOrientation.portraitDown,
		]);
	}
}
