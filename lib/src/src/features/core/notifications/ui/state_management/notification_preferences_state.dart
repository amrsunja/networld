import 'package:networld/src/src/features/core/notifications/data/models/notification_preferences_model.dart';

class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.preferences,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final NotificationPreferencesModel? preferences;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  NotificationPreferencesState copyWith({
    NotificationPreferencesModel? preferences,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
