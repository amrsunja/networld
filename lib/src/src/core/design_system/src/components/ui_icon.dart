import 'package:flutter/material.dart';

import '../../app_ui.dart';

class UIIcon extends StatelessWidget {
	final IconData icon;
	final Color? color;
	final bool defaultColor;
	final double? size;
	final Alignment? alignment;
	final VoidCallback? onTap;

	const UIIcon(
		this.icon, {
		super.key,
		this.color,
		this.defaultColor = false,
		this.size,
		this.alignment,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		final theme = AppTheme.of(context);

		return UITap(
			onTap: onTap,
			child: Transform.flip(
        //flipX: locale.languageCode == L10n.ar.languageCode || locale.languageCode == L10n.ur.languageCode,
			  child: Icon(
          icon,
			  	color: defaultColor ? null : color ?? theme.colors.contentColor,
          size: size,
        ),
			)
		);
	}
}
