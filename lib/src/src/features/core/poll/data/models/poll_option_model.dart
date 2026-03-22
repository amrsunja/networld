import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

class PollOptionModel extends Equatable {
  final int id;
  final String titleEn;
  final String titleFr;

  const PollOptionModel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
  });

  factory PollOptionModel.fromJson(Json json) {
    return PollOptionModel(
      id: (json['id'] as num).toInt(),
      titleEn: (json['title_en'] as String?) ?? '',
      titleFr: (json['title_fr'] as String?) ?? '',
    );
  }

  /// Returns the title for the given locale. Defaults to [titleEn] for non-FR.
  String titleFor(Locale locale) {
    if (locale.languageCode == 'fr' && titleFr.isNotEmpty) return titleFr;
    return titleEn.isNotEmpty ? titleEn : titleFr;
  }

  Json toJson() => {
        'id': id,
        'title_en': titleEn,
        'title_fr': titleFr,
      };

  @override
  List<Object?> get props => [id, titleEn, titleFr];
}
