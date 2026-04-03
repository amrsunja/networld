import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/routing/app_router.gr.dart';
import 'package:brokies/src/src/core/widgets/pagination/infinity_data_scroll.dart';
import 'package:brokies/src/src/features/core/profile/ui/state_management/follow_list_provider.dart';
import 'package:brokies/src/src/features/core/profile/ui/widgets/follow_user_tile_widget.dart';

class ProfileFollowingsPage extends HookConsumerWidget {
  const ProfileFollowingsPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final key = '$userId:followings';
    final state = ref.watch(followListProvider(key));
    final scrollController = useScrollController();

    useEffect(() {
      Future.microtask(
        () => ref.read(followListProvider(key).notifier).load(refresh: true),
      );
      return null;
    }, [userId]);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: theme.colors.bgColor,
        body: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colors.secondContentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileStatFollowing,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colors.contentColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: UIColorsToken.pri350,
                backgroundColor: theme.colors.bgColor,
                onRefresh: () => ref
                    .read(followListProvider(key).notifier)
                    .load(refresh: true),
                child: InfinityDataScrollWidget(
                  scrollController: scrollController,
                  onScrollEnd: () {
                    final s = ref.read(followListProvider(key));
                    if (!s.isLoadingMore && s.hasMore) {
                      ref.read(followListProvider(key).notifier).load();
                    }
                  },
                  child: state.users.isEmpty && !state.isRefreshing
                      ? ListView(
                          controller: scrollController,
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                l10n.profileFollowingEmpty,
                                style: theme.typo.textSm.regular.copyWith(
                                  color: theme.colors.secondContentColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return FollowUserTileWidget(
                              user: user,
                              onTap: () => _navigateToUser(context, user.id),
                            );
                          },
                        ),
                ),
              ),
            ),
            if (state.isRefreshing)
              const Padding(
                padding: EdgeInsets.all(12),
                child: UICircularProgressBar(),
              ),
          ],
        ),
      ),
    );
  }
}

void _navigateToUser(BuildContext context, String userId) {
  final currentUid = supabase.auth.currentUser?.id;
  Navigator.of(context).pop();
  if (userId == currentUid) {
    context.router.navigate(const ProfileRouterRoute());
  } else {
    context.router.push(UserProfileRoute(userId: userId));
  }
}
