import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/poll/data/models/poll_option_model.dart';

/// Option stored in `posts.poll_options` when creating a poll post:
/// `{ "id": 3, "title": "maybe" }`.
class PostPollOptionModel extends Equatable {
  const PostPollOptionModel({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  factory PostPollOptionModel.fromJson(Json json) {
    return PostPollOptionModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
    );
  }

  Json toJson() => {
        'id': id,
        'title': title,
      };

  /// For [PollOptionRow] (daily/admin poll UI); same text for EN/FR.
  PollOptionModel toPollOptionModel() => PollOptionModel(
        id: id,
        titleEn: title,
        titleFr: title,
      );

  @override
  List<Object?> get props => [id, title];
}
