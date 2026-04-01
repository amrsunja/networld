import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';
import 'package:networld/src/src/features/core/avatars/ui/state_management/avatars_provider.dart';

import '../../app_ui.dart';

/// Unified avatar component used across the app.
///
/// Renders a circular avatar image resolved from [avatarId] via the catalog,
/// with optional border, verified badge, and glow effect.
///
/// Falls back to username initials when the image is unavailable.
class UIAvatar extends ConsumerWidget {
  const UIAvatar({
    super.key,
    required this.avatarId,
    required this.size,
    this.username = '',
    this.borderWidth = 0,
    this.borderColor,
    this.isVerified = false,
    this.glowColor,
    this.glowRadius,
  });

  final int avatarId;
  final double size;
  final String username;
  final double borderWidth;
  final Color? borderColor;
  final bool isVerified;

  /// Optional glow behind the avatar circle.
  final Color? glowColor;
  final double? glowRadius;

  double get _innerSize => size - borderWidth * 2;

  double get _verifiedBadgeSize {
    if (size >= 100) return 28;
    if (size >= 44) return 20;
    return 16;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(avatarCatalogProvider);
    final gold = UIColorsToken.pri350;
    final effectiveBorderColor = borderColor ?? UIColorsToken.sec400;

    final imageUrl = catalogAsync.whenOrNull(
      data: (catalog) => AvatarCatalogModel.imageUrlById(avatarId, catalog),
    );

    return SizedBox(
      width: size + (isVerified ? 4 : 0),
      height: size + (isVerified ? 4 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (glowColor != null)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor!,
                    blurRadius: glowRadius ?? 12,
                  ),
                ],
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: borderWidth > 0
                  ? Border.all(color: effectiveBorderColor, width: borderWidth)
                  : null,
            ),
            child: ClipOval(
              child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: _innerSize,
                  height: _innerSize,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => _InitialsFallback(
                    username: username,
                    size: _innerSize,
                  ),
                  errorWidget: (_, _, _) => _InitialsFallback(
                    username: username,
                    size: _innerSize,
                  ),
                )
              : _InitialsFallback(
                  username: username,
                  size: _innerSize,
                ),
            ),
          ),
          if (isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _verifiedBadgeSize,
                height: _verifiedBadgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                  border: Border.all(width: _verifiedBadgeSize > 20 ? 2 : 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.35),
                      blurRadius: _verifiedBadgeSize > 20 ? 8 : 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: _verifiedBadgeSize * 0.58,
                  color: UIColorsToken.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.username, required this.size});

  final String username;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromUsername(username);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: UIColorsToken.neu400.withValues(alpha: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w600,
          color: UIColorsToken.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

String _initialsFromUsername(String username) {
  final t = username.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s_\-]+'));
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }
  final s = parts[0];
  return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
}
