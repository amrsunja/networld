import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/design_system/src/tokens/colors/ui_colors_token.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';

@RoutePage()
class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomLift = MediaQuery.paddingOf(context).bottom + 72;

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomLift),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: UIColorsToken.pri500.withValues(alpha: 0.8),
                blurRadius: 30,
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            highlightElevation: 4,
            onPressed: () => context.router.push(const CreatePostRoute()),
            tooltip: l10n.socialCreatePost,
            backgroundColor: UIColorsToken.pri400,
            foregroundColor: UIColorsToken.black,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ),
    );
  }
}
