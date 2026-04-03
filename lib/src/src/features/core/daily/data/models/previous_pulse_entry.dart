import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_result_model.dart';

class PreviousPulseEntry {
  final DailyPollModel poll;
  final List<DailyPollResultModel> results;

  const PreviousPulseEntry({
    required this.poll,
    required this.results,
  });

  int get totalVerified => results.fold<int>(
        0,
        (sum, r) => sum + r.verifiedCount,
      );
}
