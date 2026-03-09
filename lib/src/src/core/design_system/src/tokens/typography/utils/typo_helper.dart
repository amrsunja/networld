import 'package:flutter/painting.dart';

class TypoHelper {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight extera = FontWeight.w900;

  /// Converts px line height to Flutter height multiplier
  static double lineHeight(double fontSize, double pxHeight) {
    return pxHeight / fontSize;
  }

  /// Converts percentage spacing to Flutter logical pixels
  static double letterSpacing(double fontSize, double percent) {
    return fontSize * (percent / 100);
  }
}
