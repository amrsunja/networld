import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    @Default(false) bool isSavingProfile,
    ProfileModel? profile,
    String? errorMessage,
  }) = _ProfileState;
}
