import 'package:flutter/material.dart';

import '../app_ui.dart';

class AppTheme extends InheritedWidget {
  const AppTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final UIThemeData data;

  static UIThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppTheme>()!.data;

  @override
  bool updateShouldNotify(covariant AppTheme oldWidget) {
    return data != oldWidget.data;
  }
}
