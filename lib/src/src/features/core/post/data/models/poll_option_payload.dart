import 'package:equatable/equatable.dart';

/// JSON shape stored in Supabase `poll_options`: `{ "id": 1, "title": "..." }`.
class PollOptionPayload extends Equatable {
  const PollOptionPayload({required this.id, required this.title});

  final int id;
  final String title;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
      };

  /// Assigns sequential ids `1..n` to [titles] (already trimmed, non-empty).
  static List<Map<String, dynamic>> jsonListFromTitles(List<String> titles) {
    return [
      for (var i = 0; i < titles.length; i++)
        PollOptionPayload(id: i + 1, title: titles[i]).toJson(),
    ];
  }

  @override
  List<Object?> get props => [id, title];
}
