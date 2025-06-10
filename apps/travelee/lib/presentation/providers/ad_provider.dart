import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdState {
  final bool showBannerAd;

  const AdState({
    this.showBannerAd = false,
  });

  AdState copyWith({
    bool? showBannerAd,
  }) {
    return AdState(
      showBannerAd: showBannerAd ?? this.showBannerAd,
    );
  }
}

class AdNotifier extends StateNotifier<AdState> {
  AdNotifier() : super(const AdState());

  void toggleBannerAd() {
    state = state.copyWith(showBannerAd: !state.showBannerAd);
  }

  void setBannerAdVisibility(bool isVisible) {
    state = state.copyWith(showBannerAd: isVisible);
  }
}

final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier();
}); 