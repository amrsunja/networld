import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/features/core/notifications/data/models/notification_model.dart';
import 'package:networld/src/src/features/core/notifications/ui/state_management/notifications_provider.dart';
import 'package:networld/src/src/features/core/notifications/ui/widgets/notification_tile.dart';

@RoutePage()
class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notificationsProvider);
    final scrollController = useScrollController();

    useEffect(() {
      Future.microtask(
        () => ref.read(notificationsProvider.notifier).loadNotifications(
              refresh: true,
            ),
      );
      return null;
    }, []);

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final pos = scrollController.position;
        if (pos.maxScrollExtent - pos.pixels < 480) {
          ref
              .read(notificationsProvider.notifier)
              .loadNotifications(refresh: false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.notificationsTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: _NotificationsBody(
        theme: theme,
        l10n: l10n,
        state: state,
        scrollController: scrollController,
        onRetry: () => ref
            .read(notificationsProvider.notifier)
            .loadNotifications(refresh: true),
        onMarkAsRead: (id) =>
            ref.read(notificationsProvider.notifier).markAsRead(id),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.theme,
    required this.l10n,
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onMarkAsRead,
  });

  final UIThemeData theme;
  final AppLocalizations l10n;
  final dynamic state;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final void Function(String id) onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final notifState = state as dynamic;

    if (notifState.isRefreshing &&
        (notifState.notifications as List).isEmpty) {
      return const Center(child: UICircularProgressBar());
    }

    if (notifState.errorMessage != null &&
        (notifState.notifications as List).isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notifState.errorMessage as String,
                textAlign: TextAlign.center,
                style: theme.typo.textSm.regular.copyWith(
                  color: theme.colors.secondContentColor,
                ),
              ),
              const SizedBox(height: 16),
              UIButton.primary(
                title: l10n.socialFeedRetry,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      );
    }

    final notifications =
        notifState.notifications as List<NotificationModel>;

    if (notifications.isEmpty && !(notifState.isRefreshing as bool)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Text(
            l10n.notificationsEmpty,
            textAlign: TextAlign.center,
            style: theme.typo.textMd.medium.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
        ),
      );
    }

    final itemCount = notifications.length +
        ((notifState.hasMore as bool) && (notifState.isLoadingMore as bool)
            ? 1
            : 0);

    return RefreshIndicator(
      color: UIColorsToken.pri350,
      backgroundColor: theme.colors.bgColor,
      onRefresh: () => Future.sync(onRetry),
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          kPageHorzPadding,
          12,
          kPageHorzPadding,
          100,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          if (index >= notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: UICircularProgressBar()),
            );
          }
          final notification = notifications[index];

          if (!notification.isRead) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onMarkAsRead(notification.id);
            });
          }

          return NotificationTile(
            notification: notification,
            l10n: l10n,
          );
        },
      ),
    );
  }
}
