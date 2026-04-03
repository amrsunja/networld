import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brokies/src/src/features/core/avatars/data/models/avatar_catalog_model.dart';

part 'avatars_state.freezed.dart';

@freezed
abstract class AvatarsState with _$AvatarsState {
  const factory AvatarsState({
    @Default(true) bool isLoading,
    @Default([]) List<AvatarCatalogModel> catalog,
    @Default({}) Set<int> ownedAvatarIds,
    @Default(1) int currentAvatarId,
    @Default(0) int userCredits,
    int? purchasingAvatarId,
    String? errorMessage,
  }) = _AvatarsState;
}
