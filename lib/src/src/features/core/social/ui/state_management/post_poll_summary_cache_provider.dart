import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/network/supabase.dart';

class PostPollSummaryCacheEntry {
  const PostPollSummaryCacheEntry({
    required this.myVotedOptionId,
    required this.countsByOptionId,
    required this.avgNetWorthByOptionId,
  });

  final int? myVotedOptionId;
  final Map<int, int> countsByOptionId;
  final Map<int, num?> avgNetWorthByOptionId;
}

class PostPollSummaryCacheNotifier
    extends StateNotifier<Map<String, PostPollSummaryCacheEntry>> {
  PostPollSummaryCacheNotifier()
      : _sessionUserId = supabase.auth.currentUser?.id,
        super(const {});

  String? _sessionUserId;

  /// Clears cached poll summaries when auth session user changes.
  void syncWithCurrentUser() {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == _sessionUserId) return;
    _sessionUserId = currentUserId;
    state = const {};
  }

  void put(String postId, PostPollSummaryCacheEntry entry) {
    state = {
      ...state,
      postId: entry,
    };
  }

  void remove(String postId) {
    final next = Map<String, PostPollSummaryCacheEntry>.from(state);
    next.remove(postId);
    state = next;
  }

  void clear() => state = const {};
}

final postPollSummaryCacheProvider = StateNotifierProvider<
    PostPollSummaryCacheNotifier, Map<String, PostPollSummaryCacheEntry>>(
  (ref) => PostPollSummaryCacheNotifier(),
);

