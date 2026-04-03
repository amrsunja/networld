import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brokies/src/src/core/utils/enums/rank_tier_enum.dart';

import '../../app_ui.dart';

class UIRankBadge extends StatelessWidget {
  const UIRankBadge({
    super.key,
    required this.label,
    required this.rankTier,
    this.uppercase = false,
    this.compact = false,
  });

  final String label;
  final RankTierEnum rankTier;
  final bool uppercase;
  final bool compact;

  Color get _backgroundColor {
    return switch (rankTier) {
      RankTierEnum.Starter => const Color(0xFF4A515F),
      RankTierEnum.Builder => const Color(0xFF355C4A),
      RankTierEnum.Scaler => const Color(0xFF2D5770),
      RankTierEnum.Elite => const Color(0xFF6B3E7A),
      RankTierEnum.Whale => UIColorsToken.pri350,
    };
  }

  Color get _textColor {
    return switch (rankTier) {
      RankTierEnum.Whale => UIColorsToken.black,
      _ => UIColorsToken.white,
    };
  }

  @override
  Widget build(BuildContext context) {
    final value = uppercase ? label.toUpperCase() : label;
    final horizontal = compact ? 7.0 : 8.0;
    final vertical = compact ? 2.0 : 3.0;
    final radius = compact ? 5.0 : 6.0;
    final fontSize = compact ? 9.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: _textColor,
        ),
      ),
    );
  }
}
