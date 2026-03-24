part of '../envola_typography_token.dart';

class TextMdTypo {
  final Color color;

  // Final style variables
  final TextStyle regular;
  final TextStyle medium;
  final TextStyle semibold;
  final TextStyle bold;

  TextMdTypo({required this.color}) 
      : regular = _buildStyle(TypoHelper.regular, color),
        medium = _buildStyle(TypoHelper.medium, color),
        semibold = _buildStyle(TypoHelper.semibold, color),
        bold = _buildStyle(TypoHelper.bold, color);

  static final double fontSize = 16;

  // Static helper method
  static TextStyle _buildStyle(FontWeight weight, Color color) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: TypoHelper.lineHeight(fontSize, 24),
    );
  }
}
