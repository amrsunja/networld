import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/features/core/daily/data/daily_repo.dart';
import 'package:networld/src/src/features/core/daily/data/models/previous_pulse_entry.dart';

final previousPulsesProvider =
    FutureProvider.autoDispose<List<PreviousPulseEntry>>((ref) async {
  final result = await ref.read(dailyRepoProvider).getPreviousPulses();
  return result.when(
    (data) => data,
    (failure) => throw Exception('$failure'),
  );
});
