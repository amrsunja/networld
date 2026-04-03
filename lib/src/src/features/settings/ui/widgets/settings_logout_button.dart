import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: UICircularProgressBar(),
        )
      );
    }

    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFCDCDCD),
      ),
    );
  }
}
