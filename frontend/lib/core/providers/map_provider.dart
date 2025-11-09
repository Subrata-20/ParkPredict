import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fake_api.dart';
import '../models/lot.dart';

final mapProvider =
    StateNotifierProvider<MapNotifier, MapState>((ref) => MapNotifier());

class MapState {
  final bool loading;
  final String? error;
  final List<Lot> lots;
  MapState({this.loading = false, this.error, this.lots = const []});
  MapState copyWith({bool? loading, String? error, List<Lot>? lots}) =>
      MapState(
          loading: loading ?? this.loading,
          error: error ?? this.error,
          lots: lots ?? this.lots);
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  Future<void> loadLots() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final lots = await FakeApi.getLots();
      state = state.copyWith(loading: false, lots: lots);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
