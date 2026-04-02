import 'package:flutter/material.dart';
import 'package:networld/gen/assets.gen.dart';

import 'ui_image.dart';

/// Networld credits coin icon (asset). Use next to credit amounts across the app.
class UINetworldCoin extends StatelessWidget {
  const UINetworldCoin({
    super.key,
    this.size = 18,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: UIImage.asset(
        image: Assets.icons.networldCoinIcon.path,
        boxFit: BoxFit.contain,
      ),
    );
  }
}
