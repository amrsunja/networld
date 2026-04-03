import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:brokies/gen/assets.gen.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/routing/app_router.gr.dart';
import 'package:brokies/src/src/core/utils/constants/constants.dart';
import 'package:brokies/src/src/core/utils/enums/enums.dart';
import 'package:brokies/src/src/features/core/profile/ui/state_management/profile_provider.dart';

class OnboardingCompletedPage extends HookConsumerWidget {
  const OnboardingCompletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final profile = ref.watch(profileProvider).profile;

    final netWorth = (profile?.netWorth ?? 0).toDouble();
    final currency = profile?.currency ?? CurrencyType.usd;
    final isVerified = profile?.isVerified ?? false;
    final rankTier = profile?.rankTier ?? RankTierEnum.Starter;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: -100,
              bottom: -50,
              child: SizedBox(
                height: 400,
                child: Opacity(
                  opacity: 0.15,
                  child: UIImage.asset(
                    image: Assets.images.earth2.path,
                  ),
                ),
              ),
            ).animate(effects: [FadeEffect()]).moveY(
              duration: Duration(seconds: 1),
              begin: 100,
              curve: Curves.fastOutSlowIn
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  UIIcon(
                    Iconic.badge,
                    color: UIColorsToken.pri500,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Félicitations, vous êtes désormais membre de Networld',
                    textAlign: TextAlign.center,
                    style: theme.typo.displaySm.bold.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ).animate()
                    .fade(
                      delay: Duration(milliseconds: 800),
                      duration: Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn
                    )
                    .moveY(
                      delay: Duration(milliseconds: 800),
                      duration: Duration(seconds: 1),
                      begin: 50,
                      curve: Curves.fastOutSlowIn
                    ),

                  const Spacer(),
                  _buildNetWorthCard(
                    theme: theme,
                    netWorth: netWorth,
                    currency: currency,
                    isVerified: isVerified,
                    rankTier: rankTier,
                  ).animate()
                  .fade(
                    delay: Duration(milliseconds: 1600),
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn
                  )
                  .moveY(
                    delay: Duration(milliseconds: 1600),
                    duration: Duration(seconds: 1),
                    begin: 50,
                    curve: Curves.fastOutSlowIn
                  ),
                  const Spacer(flex: 2),
                  UIButton.primary(
                    title: 'ACCÉDER À L\'APPLICATION',
                    titleStyle: theme.typo.textSm.bold.copyWith(
                      color: UIColorsToken.black
                    ),
                    suffixIcon: Icons.arrow_forward_ios,
                    height: 50,
                    fullWidth: true,
                    customRadius: 100,
                    onTap: () {
                      context.router.replaceAll([const HomeRouterRoute()]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthCard({
    required UIThemeData theme,
    required double netWorth,
    required CurrencyType currency,
    required bool isVerified,
    required RankTierEnum rankTier,
  }) {
    final rankLabel = rankTier.dbValue.toLowerCase();

    return UITransparentBluredCard(
      padding: const EdgeInsets.all(30),
      shadowBegin: .bottomLeft,
      shadowEnd: .topRight,
      customShadowColors: [
        UIColorsToken.pri350.withValues(alpha: 0.2),
        UIColorsToken.black.withValues(alpha: 0.1),
        UIColorsToken.black.withValues(alpha: 0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'VOTRE PSEUDO:',
            textAlign: TextAlign.center,
            style: theme.typo.textXs.bold.copyWith(
              color: UIColorsToken.pri350.withValues(alpha: 0.4),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                netWorth.toString(),
                style: theme.typo.displaySm.bold.copyWith(
                fontSize: 42,
                  color: UIColorsToken.pri350,
                  shadows: UIShadowToken.kTextShadow,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                currency.symbol,
                style: theme.typo.displaySm.bold.copyWith(
                  color: UIColorsToken.pri350,
                  shadows: UIShadowToken.kTextShadow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: UIDivider(
              thickness: 0.5,
              color: UIColorsToken.pri500.withValues(alpha: 0.2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUT',
                    style: theme.typo.textXs.regular.copyWith(
                      color: UIColorsToken.onboardingDescription,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isVerified)
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: UIColorsToken.pri350,
                        ),
                      if (isVerified)
                        const SizedBox(width: 4),
                      Text(
                        (isVerified ? 'VÉRIFIÉ' : 'NON VÉRIFIÉ').toUpperCase(),
                        style: theme.typo.textXs.bold.copyWith(
                          color: UIColorsToken.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RANK',
                    style: theme.typo.textXs.regular.copyWith(
                      fontSize: 9,
                      color: UIColorsToken.onboardingDescription,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rankLabel,
                    style: theme.typo.textXs.medium.copyWith(
                      color: UIColorsToken.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

