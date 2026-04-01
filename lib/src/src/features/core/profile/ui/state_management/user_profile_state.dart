import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';

class UserProfileState {
  const UserProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.isFollowing = false,
    this.isFollowLoading = false,
  });

  final bool isLoading;
  final ProfileModel? profile;
  final String? errorMessage;
  final bool isFollowing;
  final bool isFollowLoading;

  UserProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
    bool? isFollowing,
    bool? isFollowLoading,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
    );
  }
}
