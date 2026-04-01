import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';
import 'package:networld/src/src/features/core/avatars/ui/state_management/avatars_provider.dart';
import 'package:networld/src/src/features/core/avatars/ui/state_management/avatars_state.dart';

const Color _kMutedLabel = Color(0xFF808080);

@RoutePage()
class ProfileAvatarsPage extends HookConsumerWidget {
  const ProfileAvatarsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final presenter = ref.read(avatarsProvider.notifier);
    final state = ref.watch(avatarsProvider);

    useEffect(() {
      Future.microtask(() => presenter.load());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        foregroundColor: UIColorsToken.white,
        title: Text(
          l10n.avatarsPageTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          _CreditsBadge(credits: state.userCredits),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: UICircularProgressBar())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _CurrentAvatarSection(
                    state: state,
                    onRemove: state.currentAvatarId != 1
                        ? () => presenter.removeAvatar()
                        : null,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.avatarsCollectionTitle,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colors.contentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _AvatarGrid(
                    state: state,
                    onBuy: (id) => presenter.purchaseAvatar(id),
                    onSelect: (id) => presenter.selectAvatar(id),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current avatar header
// ---------------------------------------------------------------------------

class _CurrentAvatarSection extends StatelessWidget {
  const _CurrentAvatarSection({
    required this.state,
    this.onRemove,
  });

  final AvatarsState state;
  final VoidCallback? onRemove;

  static const double _avatarSize = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          UIAvatar(
            avatarId: state.currentAvatarId,
            size: _avatarSize,
            borderWidth: 3,
            borderColor: gold,
            glowColor: gold.withValues(alpha: 0.25),
            glowRadius: 24,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.avatarsCurrentLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
              color: _kMutedLabel,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: Text(l10n.avatarsResetButton),
              style: TextButton.styleFrom(
                foregroundColor: UIColorsToken.neg500,
                textStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar grid (Wrap-style via SliverGrid)
// ---------------------------------------------------------------------------

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.state,
    required this.onBuy,
    required this.onSelect,
  });

  final AvatarsState state;
  final ValueChanged<int> onBuy;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final avatar = state.catalog[index];
          final isOwned = state.ownedAvatarIds.contains(avatar.id);
          final isSelected = avatar.id == state.currentAvatarId;
          final canAfford =
              avatar.isFree || state.userCredits >= avatar.priceCredits;
          final isDisabled = !isOwned && !canAfford;

          final isBusy = state.purchasingAvatarId != null;
          final isThisPurchasing = state.purchasingAvatarId == avatar.id;

          return _AvatarGridItem(
            avatar: avatar,
            isOwned: isOwned,
            isSelected: isSelected,
            canAfford: canAfford,
            isDisabled: isDisabled,
            isBusy: isBusy,
            isThisPurchasing: isThisPurchasing,
            onBuy: () => onBuy(avatar.id),
            onSelect: () => onSelect(avatar.id),
          );
        },
        childCount: state.catalog.length,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single avatar card in the grid
// ---------------------------------------------------------------------------

class _AvatarGridItem extends StatelessWidget {
  const _AvatarGridItem({
    required this.avatar,
    required this.isOwned,
    required this.isSelected,
    required this.canAfford,
    required this.isDisabled,
    required this.isBusy,
    required this.isThisPurchasing,
    required this.onBuy,
    required this.onSelect,
  });

  final AvatarCatalogModel avatar;
  final bool isOwned;
  final bool isSelected;
  final bool canAfford;
  final bool isDisabled;

  /// Any avatar action is in progress (disables all buttons).
  final bool isBusy;

  /// This specific card is the one currently being purchased/selected.
  final bool isThisPurchasing;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isDisabled ? 0.4 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? gold
                : UIColorsToken.neu400.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? gold.withValues(alpha: 0.08)
              : UIColorsToken.black.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                width: .infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      avatar.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _AvatarPlaceholder(
                        size: 60,
                        theme: theme,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildBottomSection(context, l10n, gold, theme),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    AppLocalizations l10n,
    Color gold,
    UIThemeData theme,
  ) {
    if (isSelected) {
      return _SelectedLabel(l10n: l10n, gold: gold);
    }

    if (isOwned) {
      return _SelectButton(
        l10n: l10n,
        gold: gold,
        isBusy: isBusy,
        isThisPurchasing: isThisPurchasing,
        onTap: onSelect,
      );
    }

    return _BuySection(
      avatar: avatar,
      l10n: l10n,
      gold: gold,
      isDisabled: isDisabled,
      isBusy: isBusy,
      isThisPurchasing: isThisPurchasing,
      onTap: onBuy,
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom section variants
// ---------------------------------------------------------------------------

class _SelectedLabel extends StatelessWidget {
  const _SelectedLabel({required this.l10n, required this.gold});

  final AppLocalizations l10n;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: gold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              l10n.avatarsSelectedLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: gold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectButton extends StatelessWidget {
  const _SelectButton({
    required this.l10n,
    required this.gold,
    required this.isBusy,
    required this.isThisPurchasing,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Color gold;
  final bool isBusy;
  final bool isThisPurchasing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: isThisPurchasing
          ? const Center(child: UICircularProgressBar(size: 14))
          : TextButton(
              onPressed: isBusy ? null : onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: gold,
                textStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(l10n.avatarsSelectButton),
            ),
    );
  }
}

class _BuySection extends StatelessWidget {
  const _BuySection({
    required this.avatar,
    required this.l10n,
    required this.gold,
    required this.isDisabled,
    required this.isBusy,
    required this.isThisPurchasing,
    required this.onTap,
  });

  final AvatarCatalogModel avatar;
  final AppLocalizations l10n;
  final Color gold;
  final bool isDisabled;
  final bool isBusy;
  final bool isThisPurchasing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isThisPurchasing) {
      return const SizedBox(
        height: 40,
        child: Center(child: UICircularProgressBar(size: 14)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!avatar.isFree)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                size: 12,
                color: gold,
              ),
              const SizedBox(width: 2),
              Text(
                '${avatar.priceCredits}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: UIColorsToken.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        SizedBox(
          width: double.infinity,
          height: 26,
          child: TextButton(
            onPressed: isDisabled || isBusy ? null : onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: gold,
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              avatar.isFree
                  ? l10n.avatarsGetFreeButton
                  : l10n.avatarsBuyButton,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder
// ---------------------------------------------------------------------------

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size, required this.theme});

  final double size;
  final UIThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: UIColorsToken.neu400.withValues(alpha: 0.15),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: UIColorsToken.neu400.withValues(alpha: 0.4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Credits badge (AppBar action)
// ---------------------------------------------------------------------------

class _CreditsBadge extends StatelessWidget {
  const _CreditsBadge({required this.credits});

  final int credits;

  @override
  Widget build(BuildContext context) {
    final gold = UIColorsToken.pri350;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gold, width: 1),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.22),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            size: 18,
            color: gold,
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
