import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/poll/data/models/poll_option_model.dart';

class DailyPollModel extends Equatable {
  final String id;
  final String question;
  final String? imageUrl;
  final List<PollOptionModel>? options;

  const DailyPollModel({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
  });

  factory DailyPollModel.fromJson(Json json) {
    final optionsRaw = json['options'] as List?;

    return DailyPollModel(
      id: json['id'] as String,
      question: json['question'] as String,
      imageUrl: json['image_url'] as String?,
      options: optionsRaw?.map((e) => PollOptionModel.fromJson(e)).toList(),
    );
  }

  Json toJson() => {
    'id': id,
    'question': question,
    'image_url': imageUrl,
    'options': options?.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [id, question, imageUrl, options];
}
