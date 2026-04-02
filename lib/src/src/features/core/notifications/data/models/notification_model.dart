import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/enums/notification_type_enum.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationTypeEnum type;
  final String? refId;
  /// Follower username when [type] is [NotificationTypeEnum.new_follower] (from edge function).
  final String? refUsername;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.refId,
    this.refUsername,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationTypeEnum.fromString(json['type'] as String),
      refId: json['ref_id'] as String?,
      refUsername: json['ref_username'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationTypeEnum? type,
    String? refId,
    String? refUsername,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      refId: refId ?? this.refId,
      refUsername: refUsername ?? this.refUsername,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, type, refId, refUsername, isRead, createdAt];
}
