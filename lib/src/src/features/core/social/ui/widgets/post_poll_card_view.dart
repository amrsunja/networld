import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/poll/ui/widgets/poll_option_row.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:networld/src/src/features/core/social/ui/state_management/post_poll_summary_cache_provider.dart';

class PostPollCardView extends HookConsumerWidget {
  const PostPollCardView({
    super.key,
    required this.post,
  });

  final FeedPostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appEvents = ref.read(appEventProvider);
    final locale = Localizations.localeOf(context);
    final user = supabase.auth.currentUser;
    final userId = user?.id;
    final isMounted = useIsMounted();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isMounted()) return;
        ref.read(postPollSummaryCacheProvider.notifier).syncWithCurrentUser();
      });
      return null;
    }, [userId]);

    final cache = ref.watch(postPollSummaryCacheProvider)[post.id];

    final isLoading = useState(cache == null);
    final isVoting = useState(false);

    /// Selected option id from `votes.option_id` (matches [PostPollOptionModel.id]).
    final myVotedOptionId = useState<int?>(cache?.myVotedOptionId);
    final countsByOptionId = useState<Map<int, int>>(
      cache?.countsByOptionId ?? <int, int>{},
    );
    final avgNetWorthByOptionId = useState<Map<int, num?>>(
      cache?.avgNetWorthByOptionId ?? <int, num?>{},
    );

    useEffect(() {
      if (cache != null) {
        myVotedOptionId.value = cache.myVotedOptionId;
        countsByOptionId.value = cache.countsByOptionId;
        avgNetWorthByOptionId.value = cache.avgNetWorthByOptionId;
        isLoading.value = false;
        return null;
      }

      myVotedOptionId.value = null;
      countsByOptionId.value = <int, int>{};
      avgNetWorthByOptionId.value = <int, num?>{};
      isLoading.value = true;

      Future.microtask(() async {
        try {
          final myVote = user == null
              ? null
              : await _getMyVoteOnPost(post.id);

          final summary = await _getPostVoteSummary(post.id);
          if (!isMounted()) return;

          myVotedOptionId.value = myVote;
          countsByOptionId.value = summary.countsByOptionId;
          avgNetWorthByOptionId.value = summary.avgNetWorthByOptionId;
          ref.read(postPollSummaryCacheProvider.notifier).put(
                post.id,
                PostPollSummaryCacheEntry(
                  myVotedOptionId: myVote,
                  countsByOptionId: summary.countsByOptionId,
                  avgNetWorthByOptionId: summary.avgNetWorthByOptionId,
                ),
              );
        } catch (e) {
          if (!isMounted()) return;
          appEvents.send(
            ShowErrorEvent(
              null,
              defaultMessage: e.toString(),
            ),
          );
        } finally {
          if (!isMounted()) return;
          isLoading.value = false;
        }
      });
      return null;
    }, [post.id, cache]);

    final hasVoted = myVotedOptionId.value != null;
    final totalVotes =
        countsByOptionId.value.values.fold<int>(0, (s, v) => s + v);

    final polls = post.polls ?? const [];

    return Column(
      children: [
        for (var i = 0; i < polls.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PollOptionRow(
              option: polls[i].toPollOptionModel(),
              locale: locale,
              isSelected: hasVoted && myVotedOptionId.value == polls[i].id,
              votesCount: hasVoted
                  ? (countsByOptionId.value[polls[i].id] ?? 0)
                  : null,
              avgNetWorth:
                  hasVoted ? avgNetWorthByOptionId.value[polls[i].id] : null,
              totalVotes: hasVoted && totalVotes > 0 ? totalVotes : null,
              hasVoted: hasVoted,
              onTap: (user == null ||
                      isVoting.value ||
                      hasVoted ||
                      isLoading.value)
                  ? null
                  : () {
                      isVoting.value = true;
                      Future.microtask(() async {
                        try {
                          await _voteOnPost(
                            postId: post.id,
                            optionId: polls[i].id,
                          );
                          // refresh after successful vote
                          final newMyVote = await _getMyVoteOnPost(post.id);
                          final newSummary = await _getPostVoteSummary(post.id);
                          if (!isMounted()) return;
                          myVotedOptionId.value = newMyVote;
                          countsByOptionId.value = newSummary.countsByOptionId;
                          avgNetWorthByOptionId.value =
                              newSummary.avgNetWorthByOptionId;
                          ref.read(postPollSummaryCacheProvider.notifier).put(
                                post.id,
                                PostPollSummaryCacheEntry(
                                  myVotedOptionId: newMyVote,
                                  countsByOptionId: newSummary.countsByOptionId,
                                  avgNetWorthByOptionId:
                                      newSummary.avgNetWorthByOptionId,
                                ),
                              );
                        } catch (e) {
                          if (!isMounted()) return;
                          appEvents.send(
                            ShowErrorEvent(
                              null,
                              defaultMessage: e.toString(),
                            ),
                          );
                        } finally {
                          if (!isMounted()) return;
                          isVoting.value = false;
                        }
                      });
                    },
            ),
          ),
        ],
      ],
    );
  }

  Future<int?> _getMyVoteOnPost(String postId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final res = await supabase
        .from('votes')
        .select('option_id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    return (res?['option_id'] as num?)?.toInt();
  }

  Future<({
    Map<int, int> countsByOptionId,
    Map<int, num?> avgNetWorthByOptionId,
  })> _getPostVoteSummary(String postId) async {
    final res = await supabase.functions.invoke(
      'get-post-poll-results',
      body: {'post_id': postId},
    );
    final data = Map<String, dynamic>.from((res.data as Map?) ?? {});
    if (data['success'] != true) {
      throw Exception(data['error']?.toString() ?? 'Failed to load poll results');
    }

    final countsRaw =
        Map<String, dynamic>.from((data['counts_by_option_id'] as Map?) ?? {});
    final avgRaw = Map<String, dynamic>.from(
      (data['avg_net_worth_by_option_id'] as Map?) ?? {},
    );

    final counts = <int, int>{};
    for (final e in countsRaw.entries) {
      final optionId = int.tryParse(e.key);
      final count = (e.value as num?)?.toInt();
      if (optionId == null || count == null) continue;
      counts[optionId] = count;
    }

    final avg = <int, num?>{};
    for (final e in avgRaw.entries) {
      final optionId = int.tryParse(e.key);
      if (optionId == null) continue;
      final v = e.value;
      if (v == null) {
        avg[optionId] = null;
      } else if (v is num) {
        avg[optionId] = v;
      } else {
        avg[optionId] = num.tryParse(v.toString());
      }
    }

    return (countsByOptionId: counts, avgNetWorthByOptionId: avg);
  }

  Future<void> _voteOnPost({
    required String postId,
    required int optionId,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }

    await supabase.from('votes').insert({
      'post_id': postId,
      'user_id': userId,
      'option_id': optionId,
    });
  }
}

