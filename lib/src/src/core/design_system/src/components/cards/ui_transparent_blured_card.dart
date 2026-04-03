import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';

class UITransparentBluredCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final List<Color>? customShadowColors;
  final Alignment? shadowBegin;
  final Alignment? shadowEnd;
  final BorderRadius? borderRadius;

  const UITransparentBluredCard({
    super.key,
    required this.child,
    this.padding,
    this.customShadowColors,
    this.shadowBegin,
    this.shadowEnd,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xff1D1D1D) 
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(30),
        //color: UIColorsToken.black,
        gradient: LinearGradient(
          begin: shadowBegin ?? Alignment.topLeft,
          end: shadowEnd ?? Alignment.bottomRight,
          colors: customShadowColors ?? [
            Color(0xff181818).withValues(alpha: 0.6),
            UIColorsToken.black.withValues(alpha: 0.3),
          ]
        )
      ),
      child: child,
    ).frosted(
      blur: 5,
      frostColor: UIColorsToken.black,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }
}
