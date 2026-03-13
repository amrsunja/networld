import 'package:flutter/material.dart';

import '../../app_ui.dart';


class UIDivider extends StatelessWidget {
  const UIDivider({
    super.key,
    this.color,
    this.thickness,
  });

  final Color? color;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    return Divider(
      thickness: thickness,
      color: color ?? colors.fgColor,
    );
  }
}
