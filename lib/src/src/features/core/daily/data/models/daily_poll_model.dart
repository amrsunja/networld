import 'package:equatable/equatable.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/poll/data/models/poll_option_model.dart';

class DailyPollModel extends Equatable {
  final String id;
  final String question;
  final String? imageUrl;
  final List<PollOptionModel>? options;
  /// `admin_polls.scheduled_for` (UTC date).
  final DateTime? scheduledFor;

  const DailyPollModel({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
    this.scheduledFor,
  });

  factory DailyPollModel.fromJson(Json json) {
    final optionsRaw = json['options'] as List?;

    return DailyPollModel(
      id: json['id'] as String,
      question: json['question'] as String,
      imageUrl: json['image_url'] as String?,
      options: optionsRaw?.map((e) => PollOptionModel.fromJson(e)).toList(),
      scheduledFor: _parseScheduledFor(json['scheduled_for']),
    );
  }

  static DateTime? _parseScheduledFor(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  Json toJson() => {
    'id': id,
    'question': question,
    'image_url': imageUrl,
    'options': options?.map((e) => e.toJson()).toList(),
    if (scheduledFor != null) 'scheduled_for': scheduledFor!.toIso8601String().split('T').first,
  };

  @override
  List<Object?> get props => [id, question, imageUrl, options, scheduledFor];
}
