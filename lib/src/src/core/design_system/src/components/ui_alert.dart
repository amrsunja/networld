import 'package:flutter/material.dart';

import '../../app_ui.dart';

class UIAlert extends StatelessWidget {
	final String label;
	final Color color;
	final Color contentColor;

	const UIAlert.success({
		super.key,
		required this.label
	}) : color = UIColorsToken.pos400,
			 contentColor = UIColorsToken.white;

	const UIAlert.info({
		super.key,
		required this.label
	}) : color = UIColorsToken.pri350,
			 contentColor = UIColorsToken.black;

	const UIAlert.error({
		super.key,
		required this.label
	}) : color = UIColorsToken.neg400,
			 contentColor = UIColorsToken.white;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.circular(12)
			),
			child: Text(
				label,
        style: TextStyle(
          color: contentColor,
          fontSize: 16,
        ),
			),
		);
	}
}
