import 'package:equatable/equatable.dart';

class PowensState extends Equatable {
  const PowensState({
    this.isLoading = false,
    this.isConnectingBank = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isConnectingBank;
  final String? errorMessage;

  PowensState copyWith({
    bool? isLoading,
    bool? isConnectingBank,
    String? errorMessage,
  }) {
    return PowensState(
      isLoading: isLoading ?? this.isLoading,
      isConnectingBank: isConnectingBank ?? this.isConnectingBank,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isConnectingBank, errorMessage];
}
