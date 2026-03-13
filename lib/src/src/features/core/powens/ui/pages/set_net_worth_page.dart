import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:networld/gen/assets.gen.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/utils/app_vibrations.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/enums.dart';
import 'package:networld/src/src/features/core/powens/ui/pages/powens_webview_page.dart';
import 'package:networld/src/src/features/core/powens/ui/state_management/powens_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

@RoutePage()
class SetNetWorthPage extends HookConsumerWidget {
  const SetNetWorthPage({
    super.key,
    this.onFinish
  });

  final VoidCallback? onFinish;


  static const double _minNetWorth = -25000;
  static const double _maxNetWorth = 25000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final provider = ref.watch(powensProvider.notifier);
    final powensState = ref.watch(powensProvider);
    final profile = ref.watch(profileProvider).profile;
    final currentNetWorth = useState<double>(profile?.netWorth.toDouble() ?? 0);

    final onNetWorthSuccess = useCallback(() async {
      await ref.read(profileProvider.notifier).loadProfile();
      if (context.mounted) {
        onFinish?.call();
      }
    }, const []);

    final submitManual = useCallback(() async {
      await provider.setManualNetWorth(
        currentNetWorth.value,
        onSuccess: onNetWorthSuccess,
      );
    }, [provider, currentNetWorth.value, onNetWorthSuccess]);

    final connectPowens = useCallback(() async {
      try {
        final session = await provider.createPowensSession();
        if (!context.mounted || session == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PowensWebviewScreen(
              url: session.webviewUrl,
              onSuccess: (_) async {
                await provider.recalcNetWorthFromPowens(
                  permanentToken: session.permanentToken,
                  onSuccess: onNetWorthSuccess,
                );
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint('ERROR connectPowens: $e');
      }
    }, [provider, onNetWorthSuccess, context]);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                height: 300,
                child: Opacity(
                  opacity: 0.3,
                  child: UIImage.asset(
                    image: Assets.images.earth1.path,
                  ),
                ).animate().scale(
                  duration: Duration(seconds: 8),
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(theme)
                    .animate()
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
                    currentNetWorth: currentNetWorth.value,
                    onChanged: (value) {
                      currentNetWorth.value = value;
                    },
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
                  UIButton.secondary(
                    title: 'Continuer',
                    height: 50,
                    customRadius: 100,
                    isBusy: powensState.isLoading,
                    disabled: powensState.isLoading,
                    customBorder: BorderSide(
                      color: UIColorsToken.neu200
                    ),
                    fullWidth: true,
                    onTap: powensState.isLoading ? null : () => submitManual(),
                  ),
                  const SizedBox(height: 8),
                  UIButton.primary(
                    title: 'CONNECTER Ma Bank'.toUpperCase(),
                    prefixIcon: Iconic.bank,
                    height: 50,
                    fullWidth: true,
                    isBusy: powensState.isConnectingBank,
                    disabled: powensState.isLoading,
                    onTap: powensState.isConnectingBank || powensState.isLoading
                        ? null
                        : () => connectPowens(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UIThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UIIcon(
          Iconic.shield,
          color: UIColorsToken.pri500,
          size: 30,
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.typo.textXl.bold,
            children: [
              TextSpan(
                text: 'Ton Net Worth = ',
                style: theme.typo.displaySm.bold.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
              TextSpan(
                text: 'Ton Pseudo',
                style: theme.typo.displaySm.bold.copyWith(
                  color: UIColorsToken.onboardingTitle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connecte tes comptes bancaires de manière sécurisée via Powens ou entre manuellement ta valeur nette \n(jusqu\'à 25 000 €).',
          textAlign: TextAlign.center,
          style: theme.typo.textSm.regular.copyWith(
            fontSize: 12,
            color: UIColorsToken.onboardingDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard({
    required UIThemeData theme,
    required double currentNetWorth,
    required ValueChanged<double> onChanged,
  }) {
    return UITransparentBluredCard(
      padding: EdgeInsets.all(30),
      shadowBegin: .bottomLeft,
      shadowEnd: .topRight,
      customShadowColors: [
        UIColorsToken.pri300.withValues(alpha: 0.05),
        UIColorsToken.black.withValues(alpha: 0.1),
        UIColorsToken.black.withValues(alpha: 0.1),
        UIColorsToken.pri300.withValues(alpha: 0.05),
      ],
      child: Column(
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        children: [
          Text(
            'NET WORTH ESTIMÉ',
            textAlign: TextAlign.center,
            style: theme.typo.textXs.regular.copyWith(
              color: UIColorsToken.onboardingDescription,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentNetWorth.toString(),
                style: theme.typo.displaySm.bold.copyWith(
                  color: UIColorsToken.pri350,
                  shadows: UIShadowToken.kTextShadow,
                  fontWeight: FontWeight.w900
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CurrencyType.usd.symbol,
                style: theme.typo.displayXs.bold.copyWith(
                  color: UIColorsToken.pri350,
                  shadows: UIShadowToken.kTextShadow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            child: UIDynamicLiquidGlassSlider(
              min: _minNetWorth,
              max: _maxNetWorth,
              value: currentNetWorth.clamp(_minNetWorth, _maxNetWorth),
              onChanged: (value) {
                AppVibrations.selection();
                onChanged(value);
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_minNetWorth.toStringAsFixed(0)} €',
                style: theme.typo.textXs.medium.copyWith(
                  color: UIColorsToken.onboardingDescription,
                ),
              ),
              Text(
                '${_maxNetWorth.toStringAsFixed(0)} €',
                style: theme.typo.textXs.medium.copyWith(
                  color: UIColorsToken.onboardingDescription,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

