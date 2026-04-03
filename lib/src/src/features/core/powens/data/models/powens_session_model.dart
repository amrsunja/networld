import 'package:equatable/equatable.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';

class PowensSessionModel extends Equatable {
  final String webviewUrl;
  final String permanentToken;

  const PowensSessionModel({
    required this.webviewUrl,
    required this.permanentToken
  });

  factory PowensSessionModel.fromJson(Json json) => PowensSessionModel(
    webviewUrl: json['webview_url'],
    permanentToken: json['permanent_token'],
  );

  @override
  List<Object?> get props => [webviewUrl, permanentToken];
}
