import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/features/core/post/data/models/post_comment_model.dart';
import 'package:networld/src/src/features/core/post/ui/state_management/post_comments_provider.dart';

/// Root bottom sheet: Report + optional Delete (own comments only).
void showCommentActionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String postId,
  required PostCommentModel comment,
}) {
  final theme = AppTheme.of(context);
  final l10n = AppLocalizations.of(context);
  final uid = supabase.auth.currentUser?.id;
  final isOwn = uid != null && comment.authorId == uid;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).padding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.fgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _SheetActionRow(
                    icon: Icons.flag_outlined,
                    label: l10n.socialActionReport,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Future.microtask(
                        () => _showReportCategoryBottomSheet(
                          context,
                          ref,
                          l10n,
                          postId,
                          comment.id,
                        ),
                      );
                    },
                  ),
                  if (isOwn) ...[
                    Divider(
                      height: 1,
                      color: theme.colors.secondContentColor
                          .withValues(alpha: 0.2),
                    ),
                    _SheetActionRow(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.socialActionDelete,
                      foregroundColor: UIColorsToken.neg500,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Future.microtask(
                          () => _confirmAndDeleteComment(
                            context,
                            ref,
                            l10n,
                            postId,
                            comment.id,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _confirmAndDeleteComment(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  String postId,
  String commentId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogCtx) {
      final t = AppTheme.of(dialogCtx);
      return AlertDialog(
        backgroundColor: t.colors.fgColor,
        title: Text(
          l10n.socialDeleteCommentTitle,
          style: t.typo.textLg.bold.copyWith(color: t.colors.contentColor),
        ),
        content: Text(
          l10n.socialDeleteCannotUndoBody,
          style: t.typo.textSm.regular
              .copyWith(color: t.colors.secondContentColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              l10n.deleteAccountCancel,
              style: TextStyle(color: t.colors.secondContentColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.socialActionDelete,
              style: const TextStyle(color: UIColorsToken.neg500),
            ),
          ),
        ],
      );
    },
  );
  if (confirmed == true && context.mounted) {
    await ref.read(postCommentsProvider(postId).notifier).deleteComment(commentId);
  }
}

void _showReportCategoryBottomSheet(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  String postId,
  String commentId,
) {
  final theme = AppTheme.of(context);
  final categories = ReportCategoryEnum.values;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).padding.bottom + 12,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.fgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: theme.colors.secondContentColor
                        .withValues(alpha: 0.2),
                  ),
                _SheetActionRow(
                  icon: Icons.report_outlined,
                  label: _reportCategoryLabel(categories[i], l10n),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(postCommentsProvider(postId).notifier)
                        .reportComment(commentId, categories[i]);
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _reportCategoryLabel(ReportCategoryEnum c, AppLocalizations l10n) {
  return switch (c) {
    ReportCategoryEnum.spam => l10n.socialReportCategorySpam,
    ReportCategoryEnum.harassment => l10n.socialReportCategoryHarassment,
    ReportCategoryEnum.inappropriate => l10n.socialReportCategoryInappropriate,
    ReportCategoryEnum.other => l10n.socialReportCategoryOther,
  };
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = foregroundColor ?? theme.colors.contentColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.typo.textMd.medium.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
