import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/widgets/snackbar_widget.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:networld/src/src/features/core/social/ui/widgets/post_poll_card_view.dart';

const Color _kMetaGrey = Color(0xFF8E8E8E);

/// Card for one feed post — dark surfaces, gold accents, net worth header (matches product mocks).
class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
    this.onMoreTap,
    this.onAuthorTap,
  });

  final FeedPostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback? onCommentTap;
  /// If null, share copies [postShareUrl] to the clipboard.
  final VoidCallback? onShareTap;
  /// Overflow menu (report / delete own post). If null, the ⋯ control is hidden.
  final VoidCallback? onMoreTap;
  /// Tap on author avatar or info header. If null, area is not tappable.
  final VoidCallback? onAuthorTap;

  static const double _avatarSize = 52;
  static const String postShareBaseUrl = 'https://networld.app/post';

  String get postShareUrl => '$postShareBaseUrl/${post.id}';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;

    final author = post.author;
    final isGoldCard = author.netWorth >= 1000000;
    final meta = _buildMetaLine(l10n);
    final accent = gold;
    final likeColor = post.isLiked ? gold : _kMetaGrey;
    final heartIcon = post.isLiked ? Iconic.heart_solid : Iconic.heart_bold;

    return UITransparentBluredCard(
      borderRadius: BorderRadius.circular(16),
      shadowBegin: isGoldCard ? .topRight : null,
      shadowEnd: isGoldCard ? .bottomLeft : null,
      customShadowColors: isGoldCard ?  [
        UIColorsToken.pri350.withValues(alpha: 0.25),
        UIColorsToken.black.withValues(alpha: 0.1),
        UIColorsToken.black.withValues(alpha: 0.2),
        UIColorsToken.black.withValues(alpha: 0.3),
      ] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onAuthorTap,
                  behavior: HitTestBehavior.opaque,
                  child: UIAvatar(
                    avatarId: author.avatarId,
                    size: _avatarSize,
                    username: author.username,
                    borderWidth: 2,
                    borderColor: author.isVerified
                        ? gold
                        : UIColorsToken.sec400,
                    isVerified: author.isVerified,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onAuthorTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: UINetWorthWidget(
                                  netWorth: author.netWorth,
                                  currency: post.displayCurrency,
                                  textAlign: TextAlign.left,
                                  textStyle: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: UIRankBadge(
                                label: _localizedRankTier(author.rankTier, l10n),
                                rankTier: author.rankTier,
                                uppercase: true,
                              ),
                            ),
                            if (post.isBoosted && post.feedSlot == 'boosted') ...[
                              const SizedBox(width: 8),
                              _BoostBadge(label: l10n.socialPostBoostBadge),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meta,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.25,
                            color: _kMetaGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onMoreTap != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: theme.colors.secondContentColor,
                    ),
                    onPressed: onMoreTap,
                  ),
              ],
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: post.postType == 'poll' ? 160 : 280,
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: UIImage.network(image: post.imageUrl),
                  ),
                ),
              ),
            ],
            if (post.content != null && post.content!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.45,
                    color: theme.colors.contentColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: _hashtagSpans(
                    post.content!.trim(),
                    accent,
                    theme.colors.contentColor,
                  ),
                ),
              ),
            ],
            if (post.postType == 'poll' && (post.polls?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              PostPollCardView(post: post),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                InkWell(
                  onTap: onLikeTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(heartIcon, size: 22, color: likeColor),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likesCount}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: likeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: onCommentTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          //Icons.chat_bubble_outline_rounded,
                          Iconic.comment_alt_bold,
                          size: 20,
                          color: _kMetaGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentsCount}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kMetaGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Iconic.share_straight,
                    size: 22,
                    color: _kMetaGrey,
                  ),
                  onPressed: () => _onSharePressed(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildMetaLine(AppLocalizations l10n) {
    final time = _formatRelativeTime(post.createdAt, l10n);
    final category = _postTypeLabel(post.postType, l10n);
    final name = post.author.username.trim().isEmpty
        ? l10n.socialAuthorPlaceholder
        : post.author.username;
    return '$time • $name • $category';
  }

  void _onSharePressed(BuildContext context) {
    if (onShareTap != null) {
      onShareTap!();
      return;
    }
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: postShareUrl));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(AppSnackbarWidget.info(l10n.socialPostShareLinkCopied));
  }
}

String _postTypeLabel(String postType, AppLocalizations l10n) {
  switch (postType) {
    case 'poll':
      return l10n.socialPostTypePoll;
    case 'standard':
    default:
      return l10n.socialPostTypePost;
  }
}

String _formatRelativeTime(DateTime dt, AppLocalizations l10n) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) {
    return l10n.socialRelativeFeedSecondsAgo(diff.inSeconds);
  }
  if (diff.inMinutes < 60) {
    return l10n.socialRelativeFeedMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.socialRelativeFeedHoursAgo(diff.inHours);
  }
  if (diff.inDays < 7) {
    return l10n.socialRelativeFeedDaysAgo(diff.inDays);
  }
  return l10n.socialRelativeFeedDate(dt.day, dt.month, dt.year);
}

List<InlineSpan> _hashtagSpans(
  String text,
  Color accent,
  Color baseColor,
) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'#\w+');
  var start = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, m.start),
          style: TextStyle(color: baseColor),
        ),
      );
    }
    spans.add(
      TextSpan(
        text: text.substring(m.start, m.end),
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    start = m.end;
  }
  if (start < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(start),
        style: TextStyle(color: baseColor),
      ),
    );
  }
  return spans;
}

String _localizedRankTier(RankTierEnum tier, AppLocalizations l10n) {
  switch (tier) {
    case RankTierEnum.Starter:
      return l10n.rankTierStarter;
    case RankTierEnum.Builder:
      return l10n.rankTierBuilder;
    case RankTierEnum.Scaler:
      return l10n.rankTierScaler;
    case RankTierEnum.Elite:
      return l10n.rankTierElite;
    case RankTierEnum.Whale:
      return l10n.rankTierWhale;
  }
}

class _BoostBadge extends StatelessWidget {
  const _BoostBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: UIColorsToken.pri350.withValues(alpha: 0.65)),
        color: UIColorsToken.pri350.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: UIColorsToken.pri350,
        ),
      ),
    );
  }
}
