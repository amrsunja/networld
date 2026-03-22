import 'package:equatable/equatable.dart';

class MissionModel extends Equatable {
  final String id;
  final String title;
  final String? link;
  final int rewardCredits;
  final DateTime availableDate;

  const MissionModel({
    required this.id,
    required this.title,
    this.link,
    required this.rewardCredits,
    required this.availableDate,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    final link = json['link'] as String?;
    return MissionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      link: (link != null && link.isEmpty) ? null : link,
      rewardCredits: (json['reward_credits'] as num?)?.toInt() ?? 0,
      availableDate: DateTime.parse(json['available_date'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, link, rewardCredits, availableDate];
}
