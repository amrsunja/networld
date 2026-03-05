import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required bool isGoogleLoading,
    required bool isAppleLoading,
    required bool isAuthorized,
  }) = _AuthState;
}
