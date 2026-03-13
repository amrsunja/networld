// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/gen/assets.gen.dart';

import '../design_system/app_ui.dart';


class SplashScreenWidget extends HookConsumerWidget {
  const SplashScreenWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child:SizedBox(
          height: screen.width * 0.3,
          child: UIImage.asset(image: Assets.images.logoPng.path),
        )
      )
    );
  }
}
