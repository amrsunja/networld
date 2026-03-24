import 'package:flutter/material.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';

/// Selectable row with optional leading code (e.g. FR / EN) and selection dot.
class SettingsCheckboxTileWidget extends StatelessWidget {
  const SettingsCheckboxTileWidget({
    super.key,
    required this.isSelected,
    this.leading,
    required this.title,
    this.onTap,
  });

  final bool isSelected;
  final String? leading;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final titleColor =
        isSelected ? theme.colors.contentColor : theme.colors.secondContentColor;
    final codeColor =
        isSelected ? UIColorsToken.pri400 : theme.colors.secondContentColor;

    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? UIColorsToken.pri550 : null,
          border: Border.all(
            color: isSelected
                ? UIColorsToken.pri350.withValues(alpha: 0.35)
                : UIColorsToken.neu300.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            children: [
              if (leading != null) ...[
                Text(
                  leading!.toUpperCase(),
                  style: theme.typo.textSm.semibold.copyWith(
                    color: codeColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.typo.textMd.regular.copyWith(color: titleColor),
                ),
              ),
              if (isSelected)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: UIColorsToken.pri400,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x44FFC107),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
