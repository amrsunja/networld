import 'package:networld/src/src/core/utils/typedefs.dart';

class ClaimMissionResultModel {
  final bool success;
  final int? creditsAwarded;
  final String? error;

  const ClaimMissionResultModel({
    required this.success,
    this.creditsAwarded,
    this.error,
  });

  factory ClaimMissionResultModel.fromJson(Json data) {
    return ClaimMissionResultModel(
      success: data['success'] == true,
      creditsAwarded: (data['credits_awarded'] as num?)?.toInt(),
      error: data['error'] as String?,
    );
  }
}
