import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_provider.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/daily_missions_section.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/daily_poll_card.dart';

@RoutePage()
class DailyPage extends HookConsumerWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final dailyNotifier = ref.read(dailyProvider.notifier);
    final dailyState = ref.watch(dailyProvider);

    useEffect(() {
      Future.microtask(() async {
        await Future.wait<void>([
          dailyNotifier.loadPoll(),
          dailyNotifier.loadMissions(),
        ]);
      });
      return null;
    }, []);

    return Scaffold(
      extendBody: true,
      body: dailyState.isLoading && dailyState.poll == null
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 40),
              child: Column(
                children: [
                  if (dailyState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kPageHorzPadding,
                        vertical: 8,
                      ),
                      child: Text(
                        dailyState.errorMessage!,
                        style: theme.typo.textMd.regular.copyWith(
                          color: UIColorsToken.neg500,
                        ),
                      ),
                    ),
                  const DailyPollCard(),
                  const DailyMissionsSection(),
                ],
              ),
            ),
    );
  }
}
