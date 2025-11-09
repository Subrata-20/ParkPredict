// lib/core/services/simulation_service.dart
import 'dart:async';
import 'dart:math';
import '../models/booking.dart';

/// A simple front-end simulation engine that watches bookings and emits events:
/// - OverstayEvent: booking didn't leave at end time -> triggers conflict resolution
///
/// Use: BookingProvider will call startMonitoringBooking(booking) after booking confirm.
/// Note: Timing is scaled for demo: we schedule overstay to happen a few seconds after the end time.
class OverstayEvent {
  final String bookingId;
  final String lotId;
  OverstayEvent(this.bookingId, this.lotId);
}

class SimulationService {
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  final _rand = Random();
  final StreamController<dynamic> _controller = StreamController.broadcast();

  Stream<dynamic> get events => _controller.stream;

  final Map<String, Timer> _timers = {};

  /// Start monitoring a booking for overstay.
  /// For demo purposes: we wait a short time and then randomly trigger an overstay with some probability.
  /// If the booking duration is short, we still schedule a "possibility" after a small delay.
  void startMonitoringBooking(Booking b) {
    // clear existing timer for this booking if any
    _cancelTimer(b.id);

    // For the prototype: scale durations down:
    // - compute seconds until end
    final now = DateTime.now().toUtc();
    final secondsUntilEnd = b.endTime.toUtc().difference(now).inSeconds;
    // If booking is in future, schedule event at (end + demoGraceSec); else schedule soon.
    final demoGraceSec = 6; // grace window in seconds for prototype
    final delaySeconds =
        (secondsUntilEnd > 0) ? secondsUntilEnd + demoGraceSec : 8;

    // On trigger, randomly decide whether overstay occurs (use simple chance)
    final t = Timer(Duration(seconds: delaySeconds.clamp(6, 20)), () {
      // chance depends on a random roll — simulate more overstays if booking is short
      final roll = _rand.nextDouble();
      final chance =
          0.25 + (b.endTime.difference(b.startTime).inMinutes < 60 ? 0.2 : 0.0);
      if (roll < chance) {
        _controller.add(OverstayEvent(b.id, b.lotId));
      } else {
        // no overstay — do nothing (could add a success event)
      }
      _timers.remove(b.id);
    });

    _timers[b.id] = t;
  }

  void _cancelTimer(String bookingId) {
    final t = _timers[bookingId];
    if (t != null && t.isActive) t.cancel();
    _timers.remove(bookingId);
  }

  void cancelMonitoring(String bookingId) {
    _cancelTimer(bookingId);
  }

  void dispose() {
    for (var t in _timers.values) {
      if (t.isActive) t.cancel();
    }
    _timers.clear();
    _controller.close();
  }
}
