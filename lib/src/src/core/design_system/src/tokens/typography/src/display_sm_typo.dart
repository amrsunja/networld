part of '../ui_typography_token.dart';

class DisplaySmTypo {
  final Color color;

  // Final style variables
  final TextStyle regular;
  final TextStyle medium;
  final TextStyle semibold;
  final TextStyle bold;

  DisplaySmTypo({required this.color}) 
      : regular = _buildStyle(TypoHelper.regular, color),
        medium = _buildStyle(TypoHelper.medium, color),
        semibold = _buildStyle(TypoHelper.semibold, color),
        bold = _buildStyle(TypoHelper.bold, color);

  static final double fontSize = 30; 

  // Static helper method
  static TextStyle _buildStyle(FontWeight weight, Color color) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: TypoHelper.lineHeight(fontSize, 38),
      //letterSpacing: TypoHelper.letterSpacing(fontSize, 2)
    );
  }
}
