
import 'package:flutter/material.dart';

import '../../app_ui.dart';

class UITap extends StatelessWidget {
	const UITap({
		super.key,
		this.onTap,
		this.splashEffect = false,
		this.child,
	});

	final VoidCallback? onTap;
	final Widget? child;
	final bool splashEffect;

	@override
	Widget build(BuildContext context) {
		final color = splashEffect ? UIColorsToken.pri200 : Colors.transparent;
		return Material(
			color: Colors.transparent,
		  child: InkWell(
		  	onTap: onTap,
		  	highlightColor: color,
		  	splashColor: color,
		  	child: child,
		  ),
		);
	}
}
