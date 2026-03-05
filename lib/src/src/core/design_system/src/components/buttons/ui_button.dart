import 'package:flutter/material.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/utils/app_vibrations.dart';

class UIButton extends StatelessWidget {
  final String? title;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
	final bool disabled;
	final bool isBusy;
	final bool fullWidth;
	final Color bgColor;
	final Color fgColor;
	final Color contentColor;
	final Color? shadowColor;
	final double elevation;
	final double radius;
	final TextDecoration? titleDecoration;
  final VoidCallback? onTap;
	final BorderSide border;

  UIButton.primary({
    super.key,
    this.title,
    this.prefixIcon,
    this.suffixIcon,
    this.disabled = false,
    this.isBusy = false,
    this.fullWidth = false,
    Color? backgroundColor,
    double? customRadius,
    this.onTap,
	}) : bgColor = backgroundColor ?? Color(0xffFFD700),
			 fgColor = UIColorsToken.pri400,
			 contentColor = UIColorsToken.black,
			 shadowColor = null,
       elevation = 0,
       radius = customRadius ?? 100,
       titleDecoration = null,
			 border = BorderSide(
        width: 2,
        color: UIColorsToken.white.withValues(alpha: 0.12)
      );

  UIButton.secondary({
    super.key,
    this.title,
    this.prefixIcon,
    this.suffixIcon,
    this.disabled = false,
    this.isBusy = false,
    this.fullWidth = false,
    double? customRadius,
    this.onTap,
	}) : bgColor = UIColorsToken.black,
			 fgColor = UIColorsToken.pri400,
			 contentColor = UIColorsToken.white,
			 shadowColor = UIColorsToken.pri500,
       elevation = 4,
       radius = customRadius ?? 18,
       titleDecoration = null,
			 border = BorderSide(
        width: 0.5,
        color: UIColorsToken.pri500.withValues(alpha: 0.6)
      );


	@override
	Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    final borderRadius = BorderRadius.circular(radius);
    final bool enabled = !disabled && !isBusy && onTap != null;

    final boxShadows = <BoxShadow>[];
    if (shadowColor != null && elevation > 0) {
      boxShadows.add(
        BoxShadow(
          color: shadowColor!.withValues(alpha: 0.1),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      );
    }

		return Opacity(
			opacity: disabled ? 0.5 : 1,
		  child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: enabled
            ? () {
                AppVibrations.buttonClick();
                onTap?.call();
              }
            : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            constraints: BoxConstraints(
              minHeight: 65,
              minWidth: fullWidth ? double.infinity : 0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: title == null ? 28 : 40,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              border: Border.fromBorderSide(border),
              boxShadow: boxShadows,
            ),
            child: Center(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState:
                    isBusy ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.all(2),
                  child: UICircularProgressBar(color: contentColor),
                ),
                secondChild: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    if (prefixIcon != null) _buildIcon(prefixIcon!),
                    if (title != null)
                      Flexible(
                        flex: 4,
                        child: Text(
                          title!,
                          style: theme.typo.textSm.medium.copyWith(
                            color: contentColor,
                            overflow: TextOverflow.ellipsis,
                            decoration: titleDecoration,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (suffixIcon != null) _buildIcon(suffixIcon!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
		);
	}

	Widget _buildIcon(IconData icon) {
	  return Flexible(
	    child: Padding(
	    	padding: EdgeInsets.symmetric(
	    	),
	    	child: UIIcon(
	    		icon,
	    		color: contentColor,
	    		size: 24,
	    	),
	    ),
	  );
	}
}


