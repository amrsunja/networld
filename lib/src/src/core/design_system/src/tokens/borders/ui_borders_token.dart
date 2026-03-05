import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class UIBordersToken {
	const UIBordersToken();
	
	factory UIBordersToken.light() => const UIBordersToken();
	factory UIBordersToken.dark() => const UIBordersToken();

	OutlineInputBorder get textFieldUnfocusedBorder => _buildBorder(Color(0xffD5D7DA));
	OutlineInputBorder get textFieldFocusedBorder => _buildBorder(UIColorsToken.darkBlue.normal);
	OutlineInputBorder get textFieldErrorBorder => _buildBorder(UIColorsToken.error.normal);
	
	OutlineInputBorder _buildBorder(Color color) => OutlineInputBorder(
		borderRadius: BorderRadius.circular(8),
		borderSide: BorderSide(color: color)
	);
}
