import 'package:equatable/equatable.dart';

/// Response from recalc-networth (recal-networth).
class RecalcedNetWorthModel extends Equatable {
  const RecalcedNetWorthModel({
    required this.success,
    required this.netWorth,
    this.wasFree,
    this.rankTier,
    this.credits,
    this.nextFreeCalcAt,
    this.error,
  });
  final bool success;
  final double netWorth;
  final bool? wasFree;
  final String? rankTier;
  final int? credits;
  final String? nextFreeCalcAt;
  final String? error;

  factory RecalcedNetWorthModel.fromJson(Map<String, dynamic> json) {
    return RecalcedNetWorthModel(
      success: json['success'] as bool? ?? false,
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0,
      wasFree: json['was_free'] as bool?,
      rankTier: json['rank_tier'] as String?,
      credits: json['credits'] as int?,
      nextFreeCalcAt: json['next_free_calc_at'] as String?,
      error: json['error'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    success, netWorth, wasFree, rankTier, credits, nextFreeCalcAt, error
  ];
}
