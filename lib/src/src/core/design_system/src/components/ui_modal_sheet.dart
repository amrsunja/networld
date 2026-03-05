import 'package:flutter/material.dart';

import '../../app_ui.dart';

abstract class UIModalSheet {
	static Future<T?> modalSheet<T>({
		required BuildContext context,
		required Widget child,
		/// in percents %
		double height = 0.6,
		AnimationController? animationController,
		bool isDismissible = true,
		bool enableDrag = true,
		bool isRoot = false,
		bool showSheetLine = false,
		bool resizeToAvoidBottomInset = true,
		double? elevation,
		Color? barrierColor,
		Color? bgColor,
		Color? sheetLineColor,
		String? topBarAssetIcon,
		VoidCallback? onTopBarIconTap,
		String? topBarTitle,
		RouteSettings? routeSettings,
		EdgeInsets? padding,
	}) => showModalBottomSheet(
		routeSettings: routeSettings,
		transitionAnimationController: animationController,
		barrierColor: barrierColor ?? UIColorsToken.overlay,
		useSafeArea: true,
    showDragHandle: showSheetLine,
		useRootNavigator: isRoot,
		elevation: elevation,
		isScrollControlled: true,
		isDismissible: isDismissible,
		backgroundColor: Colors.transparent,
		enableDrag: enableDrag,
		context: context, 
		builder: (context) {
			final theme = AppTheme.of(context);
			final mediaQuery = MediaQuery.of(context);
			final deviceSize = mediaQuery.size;
			final deviceHeight = deviceSize.height;

			return Container(
				padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
				height: deviceHeight * height,
				decoration: BoxDecoration(
					color: bgColor ?? theme.colors.fgColor,
					borderRadius: const BorderRadius.vertical(
						top: Radius.circular(20)
					),
				),
				child: Scaffold(
					backgroundColor: Colors.transparent,
					resizeToAvoidBottomInset: resizeToAvoidBottomInset,
						body: Column(
						children: [
							if (topBarTitle!= null || topBarAssetIcon != null)
								Text(
									topBarTitle ?? '',
									textAlign: TextAlign.center,
                  style: TextStyle(
									  color: UIColorsToken.neu100,
                  )
								),
							Expanded(child: child)
						],
					),
				),
			);
		}
	);
}
