import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

class UserProfileState {
  const UserProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  final bool isLoading;
  final ProfileModel? profile;
  final String? errorMessage;

  UserProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
