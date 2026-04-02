import 'package:equatable/equatable.dart';

class NotificationPreferencesModel extends Equatable {
  final String userId;
  final bool likePost;
  final bool comment;
  final bool newFollower;
  final bool reward;
  final bool ranking;
  final bool system;

  const NotificationPreferencesModel({
    required this.userId,
    required this.likePost,
    required this.comment,
    required this.newFollower,
    required this.reward,
    required this.ranking,
    required this.system,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      userId: json['user_id'] as String,
      likePost: json['like_post'] as bool? ?? false,
      comment: json['comment'] as bool? ?? true,
      newFollower: json['new_follower'] as bool? ?? true,
      reward: json['reward'] as bool? ?? true,
      ranking: json['ranking'] as bool? ?? true,
      system: json['system'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'like_post': likePost,
    'comment': comment,
    'new_follower': newFollower,
    'reward': reward,
    'ranking': ranking,
    'system': system,
  };

  NotificationPreferencesModel copyWith({
    String? userId,
    bool? likePost,
    bool? comment,
    bool? newFollower,
    bool? reward,
    bool? ranking,
    bool? system,
  }) {
    return NotificationPreferencesModel(
      userId: userId ?? this.userId,
      likePost: likePost ?? this.likePost,
      comment: comment ?? this.comment,
      newFollower: newFollower ?? this.newFollower,
      reward: reward ?? this.reward,
      ranking: ranking ?? this.ranking,
      system: system ?? this.system,
    );
  }

  @override
  List<Object?> get props => [userId, likePost, comment, newFollower, reward, ranking, system];
}
