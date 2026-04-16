import 'package:auto_route/auto_route.dart';
import 'package:brokies/src/src/core/utils/app_vibrations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';
import 'package:brokies/src/src/core/utils/constants/constants.dart';
import 'package:brokies/src/src/core/utils/enums/subscription_tier_enum.dart';
import 'package:brokies/src/src/features/core/profile/data/models/profile_model.dart';
import 'package:brokies/src/src/features/core/profile/ui/state_management/profile_provider.dart';

import '../domain/shop_product_ids.dart';
import '../state/shop_iap_provider.dart';

/// Same vertical gradient as [SocialPage] feed shell.
BoxDecoration _kSocialShellGradient() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xff131209),
        UIColorsToken.black,
      ],
    ),
  );
}

// --- Stagger (same rhythm as [ProfilePage]) ----------------------------------------------------

const Duration _kShopAnimDuration = Duration(milliseconds: 720);
const int _kShopStaggerMs = 190;
const double _kShopSlideBegin = 32;

Widget _shopEnter(Widget child, int step) {
  final delayMs = step * _kShopStaggerMs;
  final delay = Duration(milliseconds: delayMs);
  return child
      .animate()
      .fade(
        delay: delay,
        duration: _kShopAnimDuration,
        curve: Curves.easeOutCubic,
      )
      .moveY(
        delay: delay,
        duration: _kShopAnimDuration,
        begin: _kShopSlideBegin,
        curve: Curves.easeOutCubic,
      );
}

const List<Shadow> _kCreditsLabelShadows = [
  Shadow(
    color: Color(0x5C000000),
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
];

class _ShopCoinBackdrop extends StatefulWidget {
  const _ShopCoinBackdrop();

  @override
  State<_ShopCoinBackdrop> createState() => _ShopCoinBackdropState();
}

class _ShopCoinBackdropState extends State<_ShopCoinBackdrop>
    with SingleTickerProviderStateMixin {
  static const Duration _kPulse = Duration(milliseconds: 3200);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kPulse)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOutCubic,
            ).value;
            final opacity = Tween<double>(begin: 0.06, end: 0.14).transform(t);
            return Align(
              alignment: const Alignment(0, -0.12),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: 2.15,
                  child: const UINetworldCoin(size: 200),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Catalog (labels / perks — store prices come from [ProductDetails]) -------------------------

const List<String> _kCreditPackProductOrder = [
  ShopProductIds.credits1000,
  ShopProductIds.credits5000,
  ShopProductIds.credits15000,
  ShopProductIds.credits50000,
  ShopProductIds.credits150000,
];

String _shopCreditsLabel(BuildContext context, String productId) {
  final n = ShopProductIds.creditsByProductId[productId] ?? 0;
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final dfK = NumberFormat('#0.0', locale);
  final String amountPart;
  switch (n) {
    case 15000:
      amountPart = '${dfK.format(15)}K';
      break;
    case 50000:
      amountPart = '${dfK.format(50)}K';
      break;
    case 150000:
      amountPart = '${dfK.format(150)}K';
      break;
    default:
      amountPart = NumberFormat.decimalPattern(locale).format(n);
  }
  return l10n.shopCreditsWithSuffix(amountPart);
}

bool _isPopularCreditPack(String productId) =>
    productId == ShopProductIds.credits15000;

class _SubscriptionUi {
  const _SubscriptionUi({
    required this.tier,
    required this.productId,
    required this.name,
    required this.perks,
    this.popularBadge = false,
  });

  final SubscriptionTier tier;
  final String productId;
  final String name;
  final List<String> perks;
  final bool popularBadge;
}

List<_SubscriptionUi> _subscriptionCatalog(AppLocalizations l10n) {
  return [
    _SubscriptionUi(
      tier: SubscriptionTier.silver,
      productId: ShopProductIds.subSilver,
      name: l10n.shopSubTierSilver,
      perks: [
        l10n.shopSubSilverPerk1,
        l10n.shopSubSilverPerk2,
        l10n.shopSubSilverPerk3,
      ],
    ),
    _SubscriptionUi(
      tier: SubscriptionTier.gold,
      productId: ShopProductIds.subGold,
      name: l10n.shopSubTierGold,
      perks: [
        l10n.shopSubGoldPerk1,
        l10n.shopSubGoldPerk2,
        l10n.shopSubGoldPerk3,
        l10n.shopSubGoldPerk4,
      ],
      popularBadge: true,
    ),
    _SubscriptionUi(
      tier: SubscriptionTier.diamond,
      productId: ShopProductIds.subDiamond,
      name: l10n.shopSubTierDiamond,
      perks: [
        l10n.shopSubDiamondPerk1,
        l10n.shopSubDiamondPerk2,
        l10n.shopSubDiamondPerk3,
        l10n.shopSubDiamondPerk4,
        l10n.shopSubDiamondPerk5,
      ],
    ),
  ];
}

// --- Page --------------------------------------------------------------------------------------

@RoutePage()
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final shop = ref.watch(shopIapProvider);
    final profile = ref.watch(profileProvider).profile;
    final notifier = ref.read(shopIapProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.shopTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.shopRestorePurchasesTooltip,
            onPressed: () => notifier.restorePurchases(),
            icon: const Icon(Icons.restore_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: _kSocialShellGradient(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _ShopCoinBackdrop(),
            Column(
              children: [
                if (shop.productsLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          kPageHorzPadding,
                          MediaQuery.paddingOf(context).top +
                              kToolbarHeight +
                              8,
                          kPageHorzPadding,
                          32,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            _buildStaggeredChildren(
                              context: context,
                              theme: theme,
                              l10n: l10n,
                              shop: shop,
                              profile: profile,
                              notifier: notifier,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStaggeredChildren({
    required BuildContext context,
    required UIThemeData theme,
    required AppLocalizations l10n,
    required ShopIapState shop,
    required ProfileModel? profile,
    required ShopIapNotifier notifier,
  }) {
    final out = <Widget>[];
    var step = 0;

    out.add(
      _shopEnter(
        _SectionTitle(
          theme: theme,
          icon: Icons.currency_exchange_rounded,
          iconColor: UIColorsToken.pri400,
          title: l10n.shopSectionCreditPacks,
        ),
        step,
      ),
    );
    step++;

    out.add(const SizedBox(height: 14));
    for (final productId in _kCreditPackProductOrder) {
      final pd = shop.product(productId);
      final busy = shop.purchasingProductIds.contains(productId);
      out.add(
        _shopEnter(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CreditPackCard(
              theme: theme,
              creditsLabel: _shopCreditsLabel(context, productId),
              priceText: pd?.price ?? '—',
              isPopular: _isPopularCreditPack(productId),
              popularBadgeLabel: l10n.shopCreditPackPopularBadge,
              isBusy: busy,
              onTap: () {
                AppVibrations.buttonClick();
                notifier.buy(productId);
              },
            ),
          ),
          step,
        ),
      );
      step++;
    }

    out.add(const SizedBox(height: 18));
    out.add(
      _shopEnter(
        _SectionTitle(
          theme: theme,
          icon: Icons.star_outline_rounded,
          iconColor: UIColorsToken.pri350,
          title: l10n.shopSectionSubscriptions,
        ),
        step,
      ),
    );
    step++;

    out.add(const SizedBox(height: 14));
    out.add(
      _SubscriptionSection(
        theme: theme,
        l10n: l10n,
        shop: shop,
        profile: profile,
        notifier: notifier,
        firstStep: step,
      ),
    );

    return out;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final UIThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.typo.textLg.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ],
    );
  }
}

class _CreditPackCard extends StatelessWidget {
  const _CreditPackCard({
    required this.theme,
    required this.creditsLabel,
    required this.priceText,
    required this.isPopular,
    required this.popularBadgeLabel,
    required this.isBusy,
    required this.onTap,
  });

  final UIThemeData theme;
  final String creditsLabel;
  final String priceText;
  final bool isPopular;
  final String popularBadgeLabel;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = theme.colors.selectColor;
    final borderColor = isPopular ? accent : theme.colors.cardBorderColor;
    final borderWidth = isPopular ? 2.0 : 1.0;

    return UITransparentBluredCard(
      borderRadius: BorderRadius.circular(14),
      shadowBegin: Alignment.topRight,
      shadowEnd: Alignment.bottomLeft,
      customShadowColors: [
        UIColorsToken.neu600.withValues(alpha: 0.5),
        UIColorsToken.black.withValues(alpha: 0.28),
        accent.withValues(alpha: isPopular ? 0.18 : 0.08),
      ],
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        child: UITap(
          onTap: isBusy ? () {} : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: UIColorsToken.neu600,
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: UINetworldCoin(size: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creditsLabel,
                        style: theme.typo.textMd.semibold.copyWith(
                          color: theme.colors.contentColor,
                          shadows: _kCreditsLabelShadows,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(height: 4),
                        Text(
                          popularBadgeLabel,
                          style: theme.typo.textXs.semibold.copyWith(
                            color: UIColorsToken.pri500,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBusy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: UICircularProgressBar(),
                  )
                else
                  Text(
                    priceText,
                    style: theme.typo.textMd.semibold.copyWith(
                      color: accent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({
    required this.theme,
    required this.l10n,
    required this.shop,
    required this.profile,
    required this.notifier,
    required this.firstStep,
  });

  final UIThemeData theme;
  final AppLocalizations l10n;
  final ShopIapState shop;
  final ProfileModel? profile;
  final ShopIapNotifier notifier;
  final int firstStep;

  @override
  Widget build(BuildContext context) {
    var step = firstStep;
    final children = <Widget>[];
    final subs = _subscriptionCatalog(l10n);

    for (var i = 0; i < subs.length; i++) {
      final sub = subs[i];
      final pd = shop.product(sub.productId);
      final priceLine = pd != null
          ? l10n.shopSubscriptionPricePerMonth(pd.price)
          : '—';
      final busy = shop.purchasingProductIds.contains(sub.productId);

      final active = _subscriptionActive(profile, sub.tier);

      children.add(
        _shopEnter(
          Padding(
            padding: EdgeInsets.only(bottom: i < subs.length - 1 ? 12 : 0),
            child: _SubscriptionCard(
              theme: theme,
              l10n: l10n,
              name: sub.name,
              priceLine: priceLine,
              perks: sub.perks,
              popularBadge: sub.popularBadge,
              isBusy: busy,
              isActive: active,
              onSubscribe: () => notifier.buy(sub.productId),
            ),
          ),
          step,
        ),
      );
      step++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  bool _subscriptionActive(ProfileModel? profile, SubscriptionTier tier) {
    if (profile == null) return false;
    if (profile.subscriptionTier != tier) return false;
    final exp = profile.subscriptionExpiresAt;
    if (exp == null) return false;
    return exp.isAfter(DateTime.now());
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.theme,
    required this.l10n,
    required this.name,
    required this.priceLine,
    required this.perks,
    required this.popularBadge,
    required this.isBusy,
    required this.isActive,
    required this.onSubscribe,
  });

  final UIThemeData theme;
  final AppLocalizations l10n;
  final String name;
  final String priceLine;
  final List<String> perks;
  final bool popularBadge;
  final bool isBusy;
  final bool isActive;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final accent = theme.colors.selectColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        UITransparentBluredCard(
          borderRadius: BorderRadius.circular(16),
          shadowBegin: Alignment.topLeft,
          shadowEnd: Alignment.bottomRight,
          customShadowColors: [
            UIColorsToken.neu600.withValues(alpha: 0.52),
            UIColorsToken.black.withValues(alpha: 0.22),
            UIColorsToken.pri500.withValues(alpha: 0.14),
            UIColorsToken.black.withValues(alpha: 0.35),
          ],
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: popularBadge ? accent : theme.colors.cardBorderColor,
                width: popularBadge ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.typo.textLg.semibold.copyWith(
                            color: theme.colors.contentColor,
                          ),
                        ),
                      ),
                      Text(
                        priceLine,
                        style: theme.typo.textMd.semibold.copyWith(
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...perks.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: UIColorsToken.pos500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line,
                              style: theme.typo.textSm.regular.copyWith(
                                color: theme.colors.contentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isActive)
                    Text(
                      l10n.shopSubscriptionActive,
                      textAlign: TextAlign.center,
                      style: theme.typo.textSm.medium.copyWith(
                        color: UIColorsToken.pos500,
                      ),
                    )
                  else
                    UIButton.primary(
                      title: l10n.shopSubscribe,
                      prefixIcon: Icons.bolt_rounded,
                      fullWidth: true,
                      height: 52,
                      customRadius: 100,
                      isBusy: isBusy,
                      disabled: isBusy,
                      onTap: () {
                        AppVibrations.buttonClick();
                        onSubscribe();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        if (popularBadge)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.shopSubscriptionPopularRibbon,
                  style: theme.typo.textXs.semibold.copyWith(
                    color: theme.colors.fgColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
