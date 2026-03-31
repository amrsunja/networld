import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
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
  });

  final FeedPostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  static const double _avatarSize = 52;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;

    final author = post.author;
    final isGoldCard = author.netWorth >= 1000000;
    final initials = _initialsFromUsername(author.username);
    final meta = _buildMetaLine();
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
                _FeedAvatar(
                  initials: initials,
                  isVerified: author.isVerified,
                  gold: gold,
                  size: _avatarSize,
                ),
                const SizedBox(width: 12),
                Expanded(
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
                          if (_isWhale(author.rankTier)) ...[
                            const SizedBox(width: 8),
                            _WhaleBadge(label: l10n.rankTierWhale.toUpperCase()),
                          ],
                          if (post.isBoosted && post.feedSlot == 'boosted') ...[
                            const SizedBox(width: 8),
                            _BoostBadge(),
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
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: theme.colors.secondContentColor,
                  ),
                  onPressed: () {},
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
                          '+${post.likesCount} CR',
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
                  onPressed: onShareTap ?? () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildMetaLine() {
    final time = _formatRelativeTime(post.createdAt);
    final category = _postTypeLabel(post.postType);
    final name = post.author.username.trim().isEmpty ? '—' : post.author.username;
    return '$time • $name • $category';
  }
}

bool _isWhale(RankTierEnum tier) => tier == RankTierEnum.Whale;

String _postTypeLabel(String postType) {
  switch (postType) {
    case 'poll':
      return 'Poll';
    case 'standard':
    default:
      return 'Post';
  }
}

String _formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
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

String _initialsFromUsername(String username) {
  final t = username.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }
  final s = parts[0];
  return s.length >= 2
      ? s.substring(0, 2).toUpperCase()
      : s.toUpperCase();
}

class _FeedAvatar extends StatelessWidget {
  const _FeedAvatar({
    required this.initials,
    required this.isVerified,
    required this.gold,
    required this.size,
  });

  final String initials;
  final bool isVerified;
  final Color gold;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = isVerified ? gold : UIColorsToken.sec400;

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              color: UIColorsToken.black.withValues(alpha: 0.85),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w600,
                color: UIColorsToken.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          if (isVerified)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                  border: Border.all(color: UIColorsToken.neu500, width: 1.5),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 12,
                  color: UIColorsToken.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WhaleBadge extends StatelessWidget {
  const _WhaleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: UIColorsToken.pri350,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: UIColorsToken.black,
        ),
      ),
    );
  }
}

class _BoostBadge extends StatelessWidget {
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
        'BOOST',
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
