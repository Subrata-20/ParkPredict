// lib/core/providers/prediction_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fake_api.dart';
import '../models/lot.dart';

final predictionProvider =
    Provider<PredictionService>((ref) => PredictionService());

class PredictionService {
  /// Returns a simple availability probability 0..1 based on ratio of available/total,
  /// with a lightweight heuristic to simulate busy hours.
  double predictAvailability(Lot lot) {
    if (lot.totalSpots == 0) return 0.0;
    final ratio = lot.available / lot.totalSpots;
    // simulate slight temporal noise: favor lower probability if available small
    final p = (0.5 * ratio) + 0.25; // shift baseline so not too close to zero
    return p.clamp(0.0, 1.0);
  }
}
