import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingState {
  final bool isLoading;
  final String? message;

  const LoadingState({
    this.isLoading = false,
    this.message,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? message,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

class LoadingStateNotifier extends StateNotifier<LoadingState> {
  LoadingStateNotifier() : super(const LoadingState());

  void startLoading({String? message}) {
    state = LoadingState(isLoading: true, message: message);
  }

  void stopLoading() {
    state = const LoadingState(isLoading: false);
  }

  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }
}

final loadingStateProvider =
    StateNotifierProvider<LoadingStateNotifier, LoadingState>((ref) {
  return LoadingStateNotifier();
}); 