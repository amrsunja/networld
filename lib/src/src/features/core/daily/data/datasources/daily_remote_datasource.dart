import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/daily/data/models/claim_mission_result_model.dart';
import 'package:networld/src/src/features/core/daily/data/models/daily_poll_model.dart';
import 'package:networld/src/src/features/core/daily/data/models/daily_poll_result_model.dart';
import 'package:networld/src/src/features/core/daily/data/models/mission_model.dart';

final dailyRemoteDatasourceProvider = Provider<DailyRemoteDatasource>(
  (ref) => DailyRemoteDatasource(),
);

class DailyRemoteDatasource {
  static const _adminPollsTable = 'admin_polls';
  static const _votesTable = 'votes';
  static const _missionsTable = 'missions';
  static const _dailyClaimsTable = 'daily_claims';
  static const _claimDailyRewardFn = 'claim-daily-reward';

  /// Today's active poll + current user's vote (join `votes`), no gift/missions.
  Future<({DailyPollModel poll, int? userVotedOptionId})?> getActivePollWithUserState() async {
    final today = _todayIsoDate();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from(_adminPollsTable)
        .select('*, votes!left(option_id)')
        .eq('scheduled_for', today)
        .eq('is_active', true)
        .eq('votes.user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    final votesList = data['votes'] as List? ?? [];
    final hasVoted = votesList.isNotEmpty;
    final myVoteOptionId = hasVoted ? (votesList[0]['option_id'] as num?)?.toInt() : null;

    return (
      poll: DailyPollModel.fromJson(data),
      userVotedOptionId: myVoteOptionId,
    );
  }

  /// Returns the option_id the current user voted for, or null if not voted.
  Future<int?> getUserVote(String pollId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from(_votesTable)
        .select('option_id')
        .eq('poll_id', pollId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return (response['option_id'] as num?)?.toInt();
  }

  /// Inserts a vote. Throws on duplicate (unique index) or RLS violation.
  Future<void> castVote(String pollId, int optionId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await supabase.from(_votesTable).insert({
      'user_id': userId,
      'poll_id': pollId,
      'option_id': optionId,
    });
  }

  /// Calls get_poll_results RPC. Returns list of results per option_id.
  Future<List<DailyPollResultModel>> getPollResults(String pollId) async {
    final results = await supabase.rpc(
      'get_poll_results',
      params: {'p_poll_id': pollId},
    );

    if (results == null || results is! List) return [];
    final list = results;
    return list
        .map((e) => DailyPollResultModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  /// Active missions scheduled for today (admin content: video, website visit, etc.).
  Future<List<MissionModel>> getMissionsForToday() async {
    final today = _todayIsoDate();
    final rows = await supabase
        .from(_missionsTable)
        .select('id, title, link, reward_credits, available_date')
        .eq('available_date', today)
        .eq('is_active', true)
        .order('created_at');

    if (rows is! List) return [];
    return rows
        .map((e) => MissionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Mission `ref_id`s already claimed today (`claim_type` = mission).
  Future<Set<String>> getClaimedMissionRefIdsToday() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final today = _todayIsoDate();
    final rows = await supabase
        .from(_dailyClaimsTable)
        .select('ref_id')
        .eq('user_id', userId)
        .eq('claim_type', 'mission')
        .eq('claim_date', today);

    if (rows is! List) return {};
    final ids = <String>{};
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      final ref = map['ref_id'] as String?;
      if (ref != null) ids.add(ref);
    }
    return ids;
  }

  /// Awards credits via Edge Function (mirrors `missions.reward_credits` server-side).
  Future<ClaimMissionResultModel> claimMissionReward(String missionId) async {
    final res = await supabase.functions.invoke(
      _claimDailyRewardFn,
      body: <String, dynamic>{
        'claim_type': 'mission',
        'ref_id': missionId,
      },
    );

    final data = (res.data as Json?) ?? {};
    final parsed = ClaimMissionResultModel.fromJson(data);

    if (!parsed.success) {
      throw ServerException.fromErrorCode(parsed.error);
    }

    return parsed;
  }

  static String _todayIsoDate() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
