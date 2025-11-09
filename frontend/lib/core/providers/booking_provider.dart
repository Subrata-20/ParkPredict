// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/fake_api.dart';
// import '../models/booking.dart';

// final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>(
//     (ref) => BookingNotifier());

// class BookingState {
//   final bool loading;
//   final String? error;
//   final Booking? active;
//   BookingState({this.loading = false, this.error, this.active});
//   BookingState copyWith({bool? loading, String? error, Booking? active}) =>
//       BookingState(
//           loading: loading ?? this.loading,
//           error: error ?? this.error,
//           active: active ?? this.active);
// }

// class BookingNotifier extends StateNotifier<BookingState> {
//   BookingNotifier() : super(BookingState()) {
//     _loadActive();
//   }

//   Future<void> _loadActive() async {
//     state = state.copyWith(loading: true);
//     try {
//       final b = await FakeApi.getActiveBooking();
//       state = state.copyWith(loading: false, active: b);
//     } catch (e) {
//       state = state.copyWith(loading: false, error: e.toString());
//     }
//   }

//   Future<void> createBooking(
//       {required String userId,
//       required String lotId,
//       String? spotId,
//       required DateTime start,
//       required DateTime end}) async {
//     state = state.copyWith(loading: true, error: null);
//     try {
//       final b = await FakeApi.createBooking(
//           userId: userId, lotId: lotId, spotId: spotId, start: start, end: end);
//       state = state.copyWith(loading: false, active: b);
//     } catch (e) {
//       state = state.copyWith(loading: false, error: e.toString());
//     }
//   }

//   Future<void> cancelBooking(String bookingId) async {
//     state = state.copyWith(loading: true, error: null);
//     try {
//       await FakeApi.cancelBooking(bookingId);
//       state = state.copyWith(loading: false, active: null);
//     } catch (e) {
//       state = state.copyWith(loading: false, error: e.toString());
//     }
//   }
// }

// lib/core/providers/booking_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fake_api.dart';
import '../services/simulation_service.dart';
import '../models/booking.dart';
import '../models/lot.dart';

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final notifier = BookingNotifier();
  // subscribe to simulation events
  notifier._bindSimulation();
  return notifier;
});

class BookingState {
  final bool loading;
  final String? error;
  final Booking? active;
  final String? lastEventMessage; // simple human message for UI notifications
  BookingState(
      {this.loading = false, this.error, this.active, this.lastEventMessage});

  BookingState copyWith(
          {bool? loading,
          String? error,
          Booking? active,
          String? lastEventMessage}) =>
      BookingState(
        loading: loading ?? this.loading,
        error: error ?? this.error,
        active: active ?? this.active,
        lastEventMessage: lastEventMessage ?? this.lastEventMessage,
      );
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  final SimulationService _sim = SimulationService();
  StreamSubscription? _simSub;

  void _bindSimulation() {
    _simSub ??= _sim.events.listen((evt) async {
      if (evt is OverstayEvent) {
        await _handleOverstay(evt);
      }
    });
  }

  Future<void> _handleOverstay(OverstayEvent evt) async {
    final active = state.active;
    if (active == null || active.id != evt.bookingId) return;

    state = state.copyWith(
        lastEventMessage:
            'Overstay detected for your booking. Attempting reassign...');

    final alternative = await FakeApi.findNearbyWithAvailability(active.lotId);
    if (alternative != null) {
      final newSpotId = await FakeApi.allocateSpot(alternative.id);
      if (newSpotId != null) {
        final reassigned = Booking(
          id: active.id,
          userId: active.userId,
          lotId: alternative.id,
          spotId: newSpotId,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          status: 'REASSIGNED',
          priceCents: active.priceCents,
        );
        await FakeApi.releaseSpot(active.lotId);
        state = state.copyWith(
            active: reassigned,
            lastEventMessage:
                'We re-assigned you to ${alternative.name}. Tap to view.');
        _sim.startMonitoringBooking(reassigned);
        return;
      }
    }

    state = state.copyWith(
        lastEventMessage:
            'Could not reassign automatically. Please choose an action (waitlist / cancel).');
  }

  Future<void> createBooking(
      {required String userId,
      required String lotId,
      String? spotId,
      required DateTime start,
      required DateTime end}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final lot = await FakeApi.getLotById(lotId);
      if (lot == null) throw Exception('Lot not found');

      if (lot.available <= 0) {
        final wait = Booking(
          id: 'wait-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          lotId: lotId,
          spotId: null,
          startTime: start,
          endTime: end,
          status: 'WAITLIST',
          priceCents: 0,
        );
        state = state.copyWith(
            loading: false,
            active: wait,
            lastEventMessage:
                'No spots available. Added to waitlist. Suggesting alternatives.');
        return;
      }

      final allocatedSpot = await FakeApi.allocateSpot(lotId);
      if (allocatedSpot == null) {
        final wait = Booking(
          id: 'wait-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          lotId: lotId,
          spotId: null,
          startTime: start,
          endTime: end,
          status: 'WAITLIST',
          priceCents: 0,
        );
        state = state.copyWith(
            loading: false,
            active: wait,
            lastEventMessage:
                'Could not allocate spot. You are on the waitlist.');
        return;
      }

      final b = Booking(
        id: _makeBookingId(),
        userId: userId,
        lotId: lotId,
        spotId: allocatedSpot,
        startTime: start,
        endTime: end,
        status: 'CONFIRMED',
        priceCents: 100 * 100,
      );

      state = state.copyWith(
          loading: false,
          active: b,
          lastEventMessage: 'Booking confirmed for ${lot.name}');
      _sim.startMonitoringBooking(b);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> acceptReassignment() async {
    final active = state.active;
    if (active == null) return;
    if (active.status == 'REASSIGNED') {
      final confirmed = Booking(
        id: active.id,
        userId: active.userId,
        lotId: active.lotId,
        spotId: active.spotId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 60)),
        status: 'CONFIRMED',
        priceCents: active.priceCents,
      );
      _sim.startMonitoringBooking(confirmed);
      state = state.copyWith(
          active: confirmed,
          lastEventMessage: 'Reassignment accepted — booking updated.');
    } else {
      state = state.copyWith(lastEventMessage: 'No reassignment to accept.');
    }
  }

  Future<void> declineReassignment() async {
    final active = state.active;
    if (active == null) return;
    if (active.spotId != null) {
      await FakeApi.releaseSpot(active.lotId);
    }
    state = state.copyWith(
        active: null,
        lastEventMessage: 'Reassignment declined. Booking cancelled.');
  }

  Future<void> cancelBooking(String bookingId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      _sim.cancelMonitoring(bookingId);
      final active = state.active;
      if (active != null && active.id == bookingId && active.spotId != null) {
        await FakeApi.releaseSpot(active.lotId);
      }
      state = state.copyWith(
          loading: false, active: null, lastEventMessage: 'Booking cancelled.');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Suggest alternatives: simple, synchronous sort of live lots.
  /// Previously used an undefined `_delayed`; now returns a Future properly.
  Future<List<Lot>> suggestAlternatives(String excludeLotId) async {
    final live = FakeApi.liveLots();
    final filtered = live.where((l) => l.id != excludeLotId).toList();
    filtered.sort((a, b) => b.available.compareTo(a.available));
    return Future.value(filtered);
  }

  String _makeBookingId() => 'bk-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void dispose() {
    _simSub?.cancel();
    super.dispose();
  }
}
