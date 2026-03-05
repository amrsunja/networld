import 'package:flutter/material.dart';

import '../../app_ui.dart';


class UIDivider extends StatelessWidget {
  const UIDivider({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    return Divider(
      color: color ?? colors.fgColor,
    );
  }
}
