import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final provider = ref.read(profileProvider.notifier);
    final profileState = ref.watch(profileProvider);

    useEffect(() {
      Future.microtask(() async {
        await provider.loadProfile();
      });
      return null;
    }, []);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPageHorzPadding),
        child: profileState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profileState.profile != null) ...[
                    Text(
                      profileState.profile!.username,
                      style: theme.typo.displayLg.semibold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Credits: ${profileState.profile!.credits}',
                      style: theme.typo.textMd.regular,
                    ),
                    Text(
                      'Net worth: ${profileState.profile!.netWorth}',
                      style: theme.typo.textMd.regular,
                    ),
                    Text(
                      'Rank: ${profileState.profile!.rankTier.name}',
                      style: theme.typo.textMd.regular,
                    ),
                    Text(
                      'Currency: ${profileState.profile!.currency.symbol}',
                      style: theme.typo.textMd.regular,
                    ),
                  ] else if (profileState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        profileState.errorMessage!,
                        style: theme.typo.textMd.regular,
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        context.router.replaceAll(const [RootRoute()]);
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
      ),
    );
  }
}


