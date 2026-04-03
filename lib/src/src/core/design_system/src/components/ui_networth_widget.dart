import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:brokies/src/src/core/design_system/src/tokens/colors/ui_colors_token.dart';
import 'package:brokies/src/src/core/utils/enums/currency_type_enum.dart';

/// Formatted net worth display: comma-separated thousands, currency symbol, and
/// fractional digits per [CurrencyType]. Values **≥ 1,000,000** use a vertical
/// gold gradient; smaller amounts use solid white.
class UINetWorthWidget extends StatelessWidget {
  const UINetWorthWidget({
    super.key,
    required this.netWorth,
    required this.currency,
    this.textStyle,
    this.textAlign = TextAlign.center,
  });

  final num netWorth;
  final CurrencyType currency;

  /// Defaults to Inter bold; color is ignored when &lt; 1M (forced white) or
  /// when ≥ 1M (gradient replaces fill).
  final TextStyle? textStyle;
  final TextAlign textAlign;

  static const double _millionThreshold = 1000000;

  static const List<Color> _gradientColors = [
    Color(0xFFFFD700),
    Color(0xFFFDB931),
    Color(0xFFFFED86),
  ];

  @override
  Widget build(BuildContext context) {
    final formatted = _formatCurrency(netWorth, currency);
    final base = textStyle ?? GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );
    final useGradient = netWorth >= _millionThreshold;

    if (!useGradient) {
      return Text(
        formatted,
        textAlign: textAlign,
        style: base.copyWith(color: UIColorsToken.white),
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _gradientColors,
        stops: [0.0, 0.33, 1.0],
      ).createShader(bounds),
      child: Text(
        formatted,
        textAlign: textAlign,
        style: base.copyWith(color: Colors.white),
      ),
    );
  }
}

String _formatCurrency(num value, CurrencyType currency) {
  final digits = currency == CurrencyType.jpy ? 0 : 0;
  return NumberFormat.currency(
    symbol: currency.symbol,
    decimalDigits: digits,
  ).format(value);
}
