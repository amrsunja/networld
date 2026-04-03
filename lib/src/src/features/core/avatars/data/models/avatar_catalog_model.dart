import 'package:equatable/equatable.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';

class AvatarCatalogModel extends Equatable {
  final int id;
  final int priceCredits;
  final bool isFree;
  final String assetName;

  const AvatarCatalogModel({
    required this.id,
    required this.priceCredits,
    required this.isFree,
    required this.assetName,
  });

  factory AvatarCatalogModel.fromJson(Json json) {
    return AvatarCatalogModel(
      id: json['id'] as int,
      priceCredits: (json['price_credits'] as int?) ?? 0,
      isFree: (json['is_free'] as bool?) ?? false,
      assetName: json['asset_name'] as String,
    );
  }

  static const String _storageBucket = 'images';
  static const String _avatarsPath = 'avatars';

  String get imageUrl =>
      supabase.storage.from(_storageBucket).getPublicUrl('$_avatarsPath/$assetName');

  /// Finds the image URL for a given [avatarId] from a [catalog] list.
  /// Returns `null` if the ID is not found.
  static String? imageUrlById(int avatarId, List<AvatarCatalogModel> catalog) {
    for (final a in catalog) {
      if (a.id == avatarId) return a.imageUrl;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, priceCredits, isFree, assetName];
}
