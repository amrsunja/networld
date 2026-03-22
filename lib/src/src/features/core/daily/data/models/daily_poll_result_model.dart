import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

class DailyPollResultModel extends Equatable {
  final int optionId;
  final int votesCount;
  final num avgNetWorth;
  final int verifiedCount;

  const DailyPollResultModel({
    required this.optionId,
    required this.votesCount,
    required this.avgNetWorth,
    required this.verifiedCount,
  });

  factory DailyPollResultModel.fromJson(Json json) {
    return DailyPollResultModel(
      optionId: (json['option_id'] as num).toInt(),
      votesCount: (json['votes_count'] as num).toInt(),
      avgNetWorth: _parseNum(json['avg_net_worth']),
      verifiedCount: (json['verified_count'] as num).toInt(),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  Json toJson() => {
        'option_id': optionId,
        'votes_count': votesCount,
        'avg_net_worth': avgNetWorth,
        'verified_count': verifiedCount,
      };

  @override
  List<Object?> get props => [optionId, votesCount, avgNetWorth, verifiedCount];
}
