import 'package:equatable/equatable.dart';

/// Response from Edge Function `create-post`.
class CreatePostResultModel extends Equatable {
  const CreatePostResultModel({
    required this.success,
    this.postId,
    this.status,
    this.cost,
    this.balance,
    this.error,
    this.requiredCredits,
    this.currentCredits,
  });

  final bool success;
  final String? postId;
  final String? status;
  final int? cost;
  final int? balance;
  final String? error;
  final int? requiredCredits;
  final int? currentCredits;

  factory CreatePostResultModel.fromJson(Map<String, dynamic> json) {
    return CreatePostResultModel(
      success: json['success'] as bool? ?? false,
      postId: json['post_id'] as String?,
      status: json['status'] as String?,
      cost: (json['cost'] as num?)?.toInt(),
      balance: (json['balance'] as num?)?.toInt(),
      error: json['error'] as String?,
      requiredCredits: (json['required'] as num?)?.toInt(),
      currentCredits: (json['current'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [
    success,
    postId,
    status,
    cost,
    balance,
    error,
    requiredCredits,
    currentCredits,
  ];
}
