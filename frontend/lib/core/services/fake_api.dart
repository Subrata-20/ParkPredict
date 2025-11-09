// import 'dart:async';
// import '../models/lot.dart';
// import '../models/spot.dart';
// import '../models/booking.dart';
// import 'package:uuid/uuid.dart';

// final _uuid = Uuid();

// class FakeApi {
//   // Simulate network latency
//   static Future<T> _delayed<T>(T result, [int ms = 600]) async {
//     await Future.delayed(Duration(milliseconds: ms));
//     return result;
//   }

//   static List<Lot> sampleLots() {
//     return [
//       Lot(id: 'lot-1', name: 'Central Parkade', address: '12 Main St', lat: 22.5726, lng: 88.3639, totalSpots: 80, available: 12, pricePerHour: 40),
//       Lot(id: 'lot-2', name: 'Mall Parking', address: '45 Mall Rd', lat: 22.575, lng: 88.36, totalSpots: 120, available: 5, pricePerHour: 60),
//       Lot(id: 'lot-3', name: 'Campus Lot', address: 'Institute Rd', lat: 22.57, lng: 88.37, totalSpots: 40, available: 18, pricePerHour: 20),
//       Lot(id: 'lot-4', name: 'Riverside Lot', address: 'River Ave', lat: 22.569, lng: 88.366, totalSpots: 30, available: 0, pricePerHour: 30),
//     ];
//   }

//   static Future<List<Lot>> getLots({double? lat, double? lng, int radius = 5000}) async {
//     return _delayed(sampleLots());
//   }

//   static Future<List<Spot>> getSpots(String lotId) async {
//     final lots = {
//       'lot-1': 8,
//       'lot-2': 6,
//       'lot-3': 5,
//       'lot-4': 4,
//     };
//     int count = lots[lotId] ?? 5;
//     List<Spot> spots = List.generate(count, (i) {
//       final id = '\$lotId-spot-\${i+1}';
//       final status = (i % 4 == 0) ? 'occupied' : (i % 5 == 0) ? 'reserved' : 'free';
//       return Spot(id: id, label: 'S\${i+1}', types: ['compact'], isActive: true, status: status);
//     });
//     return _delayed(spots);
//   }

//   static Booking? _currentBooking;

//   static Future<Booking> createBooking({required String userId, required String lotId, String? spotId, required DateTime start, required DateTime end}) async {
//     final b = Booking(
//       id: _uuid.v4(),
//       userId: userId,
//       lotId: lotId,
//       spotId: spotId,
//       startTime: start,
//       endTime: end,
//       status: 'CONFIRMED',
//       priceCents: 100 * 100,
//     );
//     _currentBooking = b;
//     return _delayed(b, 800);
//   }

//   static Future<void> cancelBooking(String bookingId) async {
//     if (_currentBooking != null && _currentBooking!.id == bookingId) {
//       _currentBooking = null;
//     }
//     return _delayed(null, 400);
//   }

//   static Future<Booking?> getActiveBooking() async {
//     return _delayed(_currentBooking);
//   }
// }

// lib/core/services/fake_api.dart
import 'dart:async';
import '../models/lot.dart';
import '../models/spot.dart';
import '../models/booking.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class FakeApi {
  // In-memory lots state (mutable for simulation)
  static final Map<String, Lot> _lotsById = {
    for (var l in sampleLots()) l.id: l
  };

  // Simulate network latency
  static Future<T> _delayed<T>(T result, [int ms = 300]) async {
    await Future.delayed(Duration(milliseconds: ms));
    return result;
  }

  static List<Lot> sampleLots() {
    return [
      Lot(
          id: 'lot-1',
          name: 'Central Parkade',
          address: '12 Main St',
          lat: 22.5726,
          lng: 88.3639,
          totalSpots: 80,
          available: 12,
          pricePerHour: 40),
      Lot(
          id: 'lot-2',
          name: 'Mall Parking',
          address: '45 Mall Rd',
          lat: 22.575,
          lng: 88.36,
          totalSpots: 120,
          available: 5,
          pricePerHour: 60),
      Lot(
          id: 'lot-3',
          name: 'Campus Lot',
          address: 'Institute Rd',
          lat: 22.57,
          lng: 88.37,
          totalSpots: 40,
          available: 18,
          pricePerHour: 20),
      Lot(
          id: 'lot-4',
          name: 'Riverside Lot',
          address: 'River Ave',
          lat: 22.569,
          lng: 88.366,
          totalSpots: 30,
          available: 0,
          pricePerHour: 30),
    ];
  }

  // Public API

  static Future<List<Lot>> getLots(
      {double? lat, double? lng, int radius = 5000}) async {
    return _delayed(_lotsById.values.toList());
  }

  static Future<Lot?> getLotById(String id) async {
    return _delayed(_lotsById[id]);
  }

  static Future<List<Spot>> getSpots(String lotId) async {
    // return some spots with statuses; not tied to actual allocation (for prototype)
    final countMap = {'lot-1': 8, 'lot-2': 6, 'lot-3': 5, 'lot-4': 4};
    final count = countMap[lotId] ?? 5;
    final spots = List.generate(count, (i) {
      final id = '$lotId-spot-${i + 1}';
      final status = (i % 4 == 0)
          ? 'occupied'
          : (i % 5 == 0)
              ? 'reserved'
              : 'free';
      return Spot(
          id: id,
          label: 'S${i + 1}',
          types: ['compact'],
          isActive: true,
          status: status);
    });
    return _delayed(spots);
  }

  // Attempt to allocate a spot: returns a pseudo spot id if available else null
  static Future<String?> allocateSpot(String lotId,
      {bool useBuffer = false}) async {
    final lot = _lotsById[lotId];
    if (lot == null) return _delayed(null);
    if (lot.available > 0) {
      // decrement
      _lotsById[lotId] = Lot(
        id: lot.id,
        name: lot.name,
        address: lot.address,
        lat: lot.lat,
        lng: lot.lng,
        totalSpots: lot.totalSpots,
        available: lot.available - 1,
        pricePerHour: lot.pricePerHour,
      );
      // return synthetic spot id
      return _delayed('${lotId}-allocated-${_uuid.v4().substring(0, 6)}');
    } else if (useBuffer) {
      // reserve buffer (simulate temporary allocation)
      // buffer allocation chooses whether we can offer a buffer spot (small percentage)
      // We'll treat this as a success with a "buffer-" spot id but not reduce available (# for demo)
      return _delayed('${lotId}-buffer-${_uuid.v4().substring(0, 6)}');
    } else {
      return _delayed(null);
    }
  }

  // Release spot (increase available)
  static Future<void> releaseSpot(String lotId, {int count = 1}) async {
    final lot = _lotsById[lotId];
    if (lot == null) return _delayed(null);
    _lotsById[lotId] = Lot(
      id: lot.id,
      name: lot.name,
      address: lot.address,
      lat: lot.lat,
      lng: lot.lng,
      totalSpots: lot.totalSpots,
      available: (lot.available + count).clamp(0, lot.totalSpots),
      pricePerHour: lot.pricePerHour,
    );
    return _delayed(null);
  }

  // Find nearby lot with available spots (very simple search by available)
  static Future<Lot?> findNearbyWithAvailability(String excludeLotId) async {
    // choose lot with max available > 0
    Lot? candidate;
    for (var l in _lotsById.values) {
      if (l.id == excludeLotId) continue;
      if (l.available > 0) {
        if (candidate == null || l.available > candidate.available)
          candidate = l;
      }
    }
    return _delayed(candidate);
  }

  // Get all lots (live)
  static List<Lot> liveLots() => _lotsById.values.toList();

  // Force reduce (for demonstration: simulate a sudden over-occupancy causing zero-inventory)
  static Future<void> forceOccupy(String lotId, int reduceBy) async {
    final lot = _lotsById[lotId];
    if (lot == null) return _delayed(null);
    _lotsById[lotId] = Lot(
      id: lot.id,
      name: lot.name,
      address: lot.address,
      lat: lot.lat,
      lng: lot.lng,
      totalSpots: lot.totalSpots,
      available: (lot.available - reduceBy).clamp(0, lot.totalSpots),
      pricePerHour: lot.pricePerHour,
    );
    return _delayed(null);
  }
}
