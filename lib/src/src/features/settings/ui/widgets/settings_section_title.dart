import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: const Color(0xFF8A8A8A),
      ),
    );
  }
}
