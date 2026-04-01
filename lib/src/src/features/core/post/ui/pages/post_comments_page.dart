import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:networld/src/src/core/widgets/pagination/infinity_data_scroll.dart';
import 'package:networld/src/src/features/core/post/data/models/post_comment_model.dart';
import 'package:networld/src/src/features/core/post/ui/state_management/post_comments_provider.dart';
import 'package:networld/src/src/features/core/post/ui/widgets/comment_actions_bottom_sheet.dart';

class PostCommentsPage extends HookConsumerWidget {
  const PostCommentsPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(postCommentsProvider(postId));
    final notifier = ref.read(postCommentsProvider(postId).notifier);
    final inputCtrl = useTextEditingController();
    useListenable(inputCtrl);
    final textValue = inputCtrl.text;
    final scrollController = useScrollController();

    useEffect(() {
      Future.microtask(() => notifier.loadComments(refresh: true));
      return null;
    }, [postId]);

    Future<void> submit() async {
      final ok = await notifier.sendComment(inputCtrl.text);
      if (!ok) return;
      inputCtrl.clear();
    }

    final flatItems = _buildFlatItems(state.comments);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UIColorsToken.neu300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                child: Row(
                  children: [
                    Text(
                      l10n.socialCommentsTitle,
                      style: AppTheme.of(context).typo.textLg.bold.copyWith(
                            color: AppTheme.of(context).colors.contentColor,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading && state.comments.isEmpty
                    ? const Center(child: UICircularProgressBar())
                    : RefreshIndicator(
                        onRefresh: () => notifier.loadComments(refresh: true),
                        child: InfinityDataScrollWidget(
                          scrollController: scrollController,
                        onScrollEnd: () {
                          if (!state.isLoadingMore && state.hasMore) {
                            notifier.loadComments();
                          }
                        },
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              kPageHorzPadding,
                              4,
                              kPageHorzPadding,
                              12,
                            ),
                            itemCount:
                                flatItems.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i >= flatItems.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: UICircularProgressBar()),
                                );
                              }
                              final item = flatItems[i];
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: i == 0 ? 0 : (item.isChild ? 6 : 10),
                                  left: item.isChild ? 32 : 0,
                                ),
                                child: _CommentTile(
                                  comment: item.comment,
                                  isChild: item.isChild,
                                  l10n: l10n,
                                  onLike: () => notifier
                                      .toggleLikeComment(item.comment.id),
                                  onReply: () =>
                                      notifier.setReplyTarget(item.comment),
                                  onMore: () => showCommentActionsBottomSheet(
                                    context: context,
                                    ref: ref,
                                    postId: postId,
                                    comment: item.comment,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
              if (state.replyTarget != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kPageHorzPadding,
                    0,
                    kPageHorzPadding,
                    8,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: UIColorsToken.pri550,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l10n.socialCommentReplyingToPrefix}'
                              '${state.replyTarget!.username}',
                              style: AppTheme.of(context).typo.textSm.medium,
                            ),
                          ),
                          GestureDetector(
                            onTap: notifier.clearReplyTarget,
                            child: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kPageHorzPadding,
                  0,
                  kPageHorzPadding,
                  30,
                ),
                child: _CommentInput(
                  controller: inputCtrl,
                  hintText: l10n.socialCommentHint,
                  isSending: state.isSending,
                  canSend: textValue.trim().isNotEmpty,
                  hasText: textValue.isNotEmpty,
                  onSend: submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlatCommentItem {
  const _FlatCommentItem({required this.comment, required this.isChild});
  final PostCommentModel comment;
  final bool isChild;
}

List<_FlatCommentItem> _buildFlatItems(List<PostCommentModel> parents) {
  final items = <_FlatCommentItem>[];
  for (final parent in parents) {
    items.add(_FlatCommentItem(comment: parent, isChild: false));
    for (final child in parent.children) {
      items.add(_FlatCommentItem(comment: child, isChild: true));
    }
  }
  return items;
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.hintText,
    required this.isSending,
    required this.canSend,
    required this.hasText,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isSending;
  final bool canSend;
  final bool hasText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return UIInputField(
      controller: controller,
      hintText: hintText,
      textInputAction: TextInputAction.newline,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasText)
            IconButton(
              onPressed: controller.clear,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: theme.colors.secondContentColor,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: (canSend && !isSending) ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: canSend
                      ? UIColorsToken.pri350
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canSend
                        ? UIColorsToken.pri350
                        : theme.colors.secondContentColor
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: UICircularProgressBar(),
                        )
                      : Icon(
                          Icons.send,
                          size: 16,
                          color: canSend
                              ? UIColorsToken.black
                              : theme.colors.secondContentColor,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isChild,
    required this.l10n,
    required this.onLike,
    required this.onReply,
    required this.onMore,
  });

  final PostCommentModel comment;
  final bool isChild;
  final AppLocalizations l10n;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onMore;

  static const double _parentAvatarSize = 38;
  static const double _childAvatarSize = 26;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final likeColor = comment.isLiked
        ? UIColorsToken.pri350
        : theme.colors.secondContentColor;

    final avatarSize = isChild ? _childAvatarSize : _parentAvatarSize;
    final initials = _initialsFromUsername(comment.author.username);

    final nwFontSize = isChild ? 13.0 : 15.0;
    final usernameFontSize = isChild ? 10.0 : 11.0;
    final contentStyle =
        isChild ? theme.typo.textSm.regular : theme.typo.textMd.regular;
    final actionIconSize = isChild ? 14.0 : 16.0;
    final actionTextStyle = isChild ? theme.typo.textXs.medium : theme.typo.textSm.medium;

    return UITransparentBluredCard(
      borderRadius: BorderRadius.circular(isChild ? 12 : 14),
      child: Padding(
        padding: EdgeInsets.all(isChild ? 8 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: UIColorsToken.neu400.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: avatarSize * 0.36,
                        fontWeight: FontWeight.w700,
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UINetWorthWidget(
                        netWorth: comment.author.netWorth,
                        currency: CurrencyType.usd,
                        textAlign: TextAlign.left,
                        textStyle: GoogleFonts.inter(
                          fontSize: nwFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        comment.author.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: usernameFontSize,
                          fontWeight: FontWeight.w400,
                          color: theme.colors.secondContentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _relative(comment.createdAt, l10n),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colors.secondContentColor,
                  ),
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: theme.colors.secondContentColor,
                    ),
                    onPressed: onMore,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(comment.content, style: contentStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked
                            ? Iconic.heart_solid
                            : Iconic.heart_bold,
                        size: actionIconSize,
                        color: likeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likesCount}',
                        style: actionTextStyle
                            .copyWith(color: likeColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: onReply,
                  child: Text(
                    l10n.socialCommentReplyAction,
                    style: actionTextStyle.copyWith(
                      color: theme.colors.secondContentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _relative(DateTime dt, AppLocalizations l10n) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) {
    return l10n.socialRelativeCommentSeconds(diff.inSeconds);
  }
  if (diff.inMinutes < 60) {
    return l10n.socialRelativeCommentMinutes(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.socialRelativeCommentHours(diff.inHours);
  }
  return l10n.socialRelativeCommentDays(diff.inDays);
}

String _initialsFromUsername(String username) {
  if (username.isEmpty) return '?';
  final parts = username.split(RegExp(r'[\s_\-]+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
}
