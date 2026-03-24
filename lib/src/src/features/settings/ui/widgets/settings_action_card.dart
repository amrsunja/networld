import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';

class SettingsActionCard extends StatelessWidget {
  const SettingsActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final borderColor =
        isDestructive ? const Color(0x55FF4545) : const Color(0x1FFFFFFF);
    final cardColor =
        isDestructive ? const Color(0xFF17090B) : const Color(0xFF0B0B0F);
    final subtitleColor =
        isDestructive ? const Color(0xFFB07A81) : const Color(0xFF868686);
    final iconColor = isDestructive ? const Color(0xFFFF5D66) : const Color(0xFFE6E6E6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            top: BorderSide(color: borderColor, width: 1.2),
          ),
          boxShadow: isDestructive
              ? [
                  BoxShadow(
                    color: const Color(0x66FF2626),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDestructive
                    ? const Color(0x33FF3B45)
                    : const Color(0xFF1B1B21),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typo.textMd.bold.copyWith(
                      color: UIColorsToken.white
                    )
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.typo.textSm.regular
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
                  size: 24,
                ),
          ],
        ),
      ),
    );
  }
}
