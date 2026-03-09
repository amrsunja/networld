import 'package:cupertino_native/components/slider.dart';
import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class UIDynamicLiquidGlassSlider extends StatelessWidget {
  const UIDynamicLiquidGlassSlider({
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    required this.value,
    required this.onChanged
  });

  final double min;
  final double max;
  final double value;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return CNSlider(
      min: min,
      max: max,
      color: UIColorsToken.pri300,
      trackColor: UIColorsToken.neu50,
      step: 1,
      value: value,
      onChanged: onChanged,
    );
  }
}


