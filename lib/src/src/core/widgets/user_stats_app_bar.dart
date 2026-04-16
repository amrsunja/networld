import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/providers/routing/navigation_services_provider.dart';
import 'package:brokies/src/src/core/routing/app_router.gr.dart';
import 'package:brokies/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:brokies/src/src/core/utils/enums/rank_tier_enum.dart';

const Color _kRankLabelColor = Color(0xFF8E9AAF);

/// App bar showing avatar, net worth, rank, credits, and notifications.
///
/// Intended for tab home pages such as Daily; pass values from [ProfileModel] or
/// another source.
class UserStatsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const UserStatsAppBar({
    super.key,
    required this.netWorth,
    required this.currency,
    required this.rankLabel,
    required this.rankTier,
    required this.rankPrefixLabel,
    required this.credits,
    this.avatarId = 1,
    this.username,
    this.isVerified = false,
    this.onNotificationTap,
    this.hasUnreadNotifications = false,
    this.notificationTooltip,
  });

  final num netWorth;
  final CurrencyType currency;
  final String rankLabel;
  final RankTierEnum rankTier;
  /// Localized label shown before the rank name, e.g. "Rank:" / "Rang :".
  final String rankPrefixLabel;
  final int credits;
  final int avatarId;
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
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      titleSpacing: 12,
      title: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.router.navigate(const ProfileRouterRoute()),
              child: Row(
                children: [
                  UIAvatar(
                    avatarId: avatarId,
                    size: avatarSize,
                    username: username ?? '',
                    borderWidth: 2,
                    borderColor: UIColorsToken.pri500.withValues(alpha: 0.3),
                    isVerified: isVerified,
                  ),
                  const SizedBox(width: 10),
                  Column(
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rankPrefixLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _kRankLabelColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: UIRankBadge(
                              label: rankLabel,
                              rankTier: rankTier,
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _CreditsPill(
            credits: credits,
            onTap: () => ref.read(navigationServicesProvider).toShop(),
          ),
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
  const _CreditsPill({
    required this.credits,
    required this.onTap,
  });

  final int credits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
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
              const UINetworldCoin(size: 18),
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
        ),
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

