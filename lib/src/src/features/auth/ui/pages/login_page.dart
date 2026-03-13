import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:networld/gen/assets.gen.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';


@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen(
      authProvider,
      (previous, next) {
        if (previous?.isAuthorized == false && next.isAuthorized) {
          context.router.replaceAll([const HomeRouterRoute()]);
        }
      },
    );

    final theme = AppTheme.of(context);

    final rotationController = useAnimationController(
      duration: const Duration(seconds: 24),
    );
    final rotation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(rotationController),
      [rotationController],
    );
    useEffect(() {
      rotationController.repeat();
      return null;
    }, [rotationController]);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RotationTransition(
              turns: rotation,
              child: Opacity(
                opacity: 0.6,
                child: UIImage.asset(
                  image: Assets.images.earth1.path,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPageHorzPadding),
              child: Column(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Column(
                    spacing: 10,
                    children: [
                      UIIcon(
                        Iconic.globe,
                        color: UIColorsToken.pri400,
                      ),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          SizedBox(
                            height: 40,
                            child: UIImage.asset(
                              image: Assets.images.logoPng.path,
                            ),
                          ),
                          Text(
                            'etworld'.toUpperCase(),
                            style: theme.typo.displaySm.bold.copyWith(
                              letterSpacing: 3,
                              color: UIColorsToken.white
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        child: UIDivider(
                          color: UIColorsToken.pri500,
                        ),
                      )
                    ],
                  ),
            
                  UITransparentBluredCard(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Column(
                          spacing: 8,
                          children: [
                            Text(
                              'Bienvenue',
                              style: theme.typo.textXl.semibold.copyWith(
                                color: UIColorsToken.white
                              ),
                            ),
                            Text(
                              'Le cercle des initiés'.toUpperCase(),
                              style: theme.typo.textXs.medium.copyWith(
                                color: UIColorsToken.white.withValues(alpha: 0.4)
                              ),
                            ),
                          ],
                        ),
                        UISpace.vert(40),
            
                        UIButton.secondary(
                          title: 'Continue with Google',
                          customPrefixIcon: Flexible(child: UIIconsToken.toIcon(Assets.icons.google)),
                          isBusy: authState.isGoogleLoading,
                          disabled: authState.isGoogleLoading,
                          fullWidth: true,
                          onTap: () {
                            ref.read(authProvider.notifier).loginWithGoogle();
                          },
                        ),
                        UISpace.vert(10),
                        UIButton.primary(
                          title: 'Continue with Apple',
                          customPrefixIcon: Flexible(child: UIIconsToken.toIcon(Assets.icons.apple)),
                          isBusy: authState.isAppleLoading,
                          disabled: authState.isAppleLoading,
                          customRadius: 18,
                          fullWidth: true,
                          onTap: () {
                            ref.read(authProvider.notifier).loginWithApple();
                          },
                        ),
            
                        UISpace.vert(40),
                        GradientText(
                          'Sign in to access your wealth identity',
                          colors: [
                            Color(0xffF9E29C),
                            Color(0xffD4AF37),
                            Color(0xff7A5C00),
                          ],
                          
                        )
                      ],
                    ),
                  ),
            
            
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          spacing: 5,
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            VertIconTextWidget(
                              icon: Icons.verified_outlined,
                              label: 'Verified',
                            ),
                            VertIconTextWidget(
                              icon: Iconic.shield_bold,
                              label: 'Secured',
                            ),
                            VertIconTextWidget(
                              icon: Iconic.lock_alt_bold,
                              label: 'Private',
                            ),
                          ],
                        ),
                        Text(
                          'Exclusive access for verified high networth \nindividuals only.'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.typo.textXs.regular.copyWith(
                            color: UIColorsToken.white.withValues(alpha: .3),
                            fontSize: 10
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(effects: [FadeEffect()]);
  }
}

class VertIconTextWidget extends StatelessWidget {
  const VertIconTextWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;


  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      spacing: 8,
      children: [
        UIIcon(
          icon,
          color: UIColorsToken.pri500.withValues(alpha: 0.5),
          size: 15,
        ),
        Text(
          label.toUpperCase(),
          style: theme.typo.textXs.regular.copyWith(
            letterSpacing: 3,
            color: UIColorsToken.white.withValues(alpha: 0.5),
            fontSize: 10
          ),
        )
      ],
    );
  }
}

