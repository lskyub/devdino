import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'travel_provider.g.dart';

@riverpod
class TravelInfo extends _$TravelInfo {
  @override
  TravelState build() {
    return const TravelState();
  }

  void setDestination(String destination) {
    state = state.copyWith(destination: [...state.destination, destination]);
  }

  void removeDestination(String destination) {
    state = state.copyWith(destination: state.destination.where((d) => d != destination).toList());
  }

  void setDates(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
  }

  void reset() {
    state = const TravelState();
  }
}

class TravelState {
  final List<String> destination;
  final DateTime? startDate;
  final DateTime? endDate;

  const TravelState({
    this.destination = const [],
    this.startDate,
    this.endDate,
  });

  TravelState copyWith({
    List<String>? destination,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TravelState(
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
} 