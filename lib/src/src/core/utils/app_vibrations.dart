// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/services.dart';

abstract class AppVibrations {
	static Future<void> buttonClick() async {
		await HapticFeedback.mediumImpact();
	}

	static Future<void> selection() async {
		await HapticFeedback.selectionClick();
	}

	static Future<void> medium() async {
		await HapticFeedback.mediumImpact();
	}

	static Future<void> hight() async {
		await HapticFeedback.heavyImpact();
	}
}
