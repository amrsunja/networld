import 'dart:ui';

import '../../app_ui.dart';

class UIThemeData {
  UIThemeData({
    required this.brightness,
    required this.colors,
    required this.borders,
    required this.typo,
  });

  factory UIThemeData.light() => UIThemeData(
    brightness: Brightness.light,
    colors: UIColorsToken.light(),
    borders: UIBordersToken.light(),
    typo: UITypographyToken.light(),
  );

  factory UIThemeData.dark() => UIThemeData(
    brightness: Brightness.dark,
    colors: UIColorsToken.dark(),
    borders: UIBordersToken.dark(),
    typo: UITypographyToken.dark(),
  );

  final Brightness brightness;
  final UIColorsToken colors;
  final UIBordersToken borders;
  final UITypographyToken typo;
}
