import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/utils/enums/currency_type_enum.dart';

const Color _kRankLabelColor = Color(0xFF8E9AAF);

/// App bar showing avatar, net worth, rank, credits, and notifications.
///
/// Intended for tab home pages such as Daily; pass values from [ProfileModel] or
/// another source.
class UserStatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserStatsAppBar({
    super.key,
    required this.netWorth,
    required this.currency,
    required this.rankLabel,
    required this.rankPrefixLabel,
    required this.credits,
    this.username,
    this.isVerified = false,
    this.onNotificationTap,
    this.hasUnreadNotifications = false,
    this.notificationTooltip,
  });

  final num netWorth;
  final CurrencyType currency;
  final String rankLabel;
  /// Localized label shown before the rank name, e.g. "Rank:" / "Rang :".
  final String rankPrefixLabel;
  final int credits;
  final String? username;
  final bool isVerified;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;
  final String? notificationTooltip;

  static const double _toolbarHeight = 72;
  static const double avatarSize = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      titleSpacing: 12,
      title: Row(
        children: [
          _AppBarAvatar(
            username: username ?? '',
            isVerified: isVerified,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: UINetWorthWidget(
                    netWorth: netWorth,
                    currency: currency,
                    textAlign: TextAlign.start,
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: rankPrefixLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _kRankLabelColor,
                        ),
                      ),
                      TextSpan(
                        text: ' $rankLabel',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: UIColorsToken.pri350,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _CreditsPill(credits: credits),
          _NotificationBell(
            onTap: onNotificationTap,
            hasUnread: hasUnreadNotifications,
            tooltip: notificationTooltip,
          ),
        ],
      ),
    );
  }
}

class _CreditsPill extends StatelessWidget {
  const _CreditsPill({required this.credits});

  final int credits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: UIColorsToken.pri350, width: 1),
        boxShadow: [
          BoxShadow(
            color: UIColorsToken.pri350.withValues(alpha: 0.22),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            size: 18,
            color: UIColorsToken.pri350,
          ),
          const SizedBox(width: 4),
          Text(
            '$credits',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: UIColorsToken.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.onTap,
    required this.hasUnread,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final bool hasUnread;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: UIColorsToken.white,
            size: 26,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColorsToken.pri350,
                  boxShadow: [
                    BoxShadow(
                      color: UIColorsToken.pri350.withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppBarAvatar extends StatelessWidget {
  const _AppBarAvatar({
    required this.username,
    required this.isVerified,
  });

  final String username;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromUsername(username);
    const gold = UIColorsToken.pri350;

    return SizedBox(
      width: UserStatsAppBar.avatarSize + 6,
      height: UserStatsAppBar.avatarSize + 6,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: UserStatsAppBar.avatarSize,
            height: UserStatsAppBar.avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: UIColorsToken.pri500.withValues(alpha: 0.3), width: 2),
              color: UIColorsToken.black.withValues(alpha: 0.8),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UIColorsToken.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          if (isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                  border: Border.all(
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 11,
                  color: UIColorsToken.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _initialsFromUsername(String username) {
  final t = username.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }
  final s = parts[0];
  return s.length >= 2
      ? s.substring(0, 2).toUpperCase()
      : s.toUpperCase();
}
