import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class UIShadowToken {
  static BoxShadow shadow({
    double x = 0,
    double y = 0,
    double blur = 0,
    double spread = 0,
    double colorOpacity = 1,
  }) {
		return BoxShadow(
			color: UIColorsToken.shadow.withValues(alpha: colorOpacity),
			blurRadius: blur,
      spreadRadius: spread,
			offset: Offset(x, y) 
		);
  }

  static final kTextShadow = [
    Shadow(
      color: UIColorsToken.pri500.withValues(alpha: 0.5),
      blurRadius: 100
    )
  ];

  static final kXs = [
    shadow(y: 1, blur: 2, colorOpacity: 0.05)
  ];

  static final kSm = [
    shadow(y: 1, blur: 2, spread: -1, colorOpacity: 0.1),
    shadow(y: 1, blur: 3, colorOpacity: 0.1),
  ];

  static final kMd = [
    shadow(y: 2, blur: 4, spread: -2, colorOpacity: 0.06),
    shadow(y: 4, blur: 6, spread: -1, colorOpacity: 0.1),
  ];

  static final kLg = [
    shadow(y: 2, blur: 2, spread: -1, colorOpacity: 0.04),
    shadow(y: 4, blur: 6, spread: -2, colorOpacity: 0.03),
  ];

  static final kXl = [
    shadow(y: 3, blur: 3, spread: -1.5, colorOpacity: 0.04),
    shadow(y: 8, blur: 8, spread: -4, colorOpacity: 0.03),
  ];

  static final k2xl = [
    shadow(y: 4, blur: 4, spread: -2, colorOpacity: 0.04),
    shadow(y: 24, blur: 48, spread: -12, colorOpacity: 0.18),
  ];

  static final k3xl = [
    shadow(y: 5, blur: 5, spread: -2.5, colorOpacity: 0.04),
    shadow(y: 32, blur: 64, spread: -12, colorOpacity: 0.14),
  ];
}
