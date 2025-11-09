// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/providers/booking_provider.dart';
// import 'package:intl/intl.dart';

// class ActiveBookingScreen extends ConsumerWidget {
//   const ActiveBookingScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(bookingProvider);
//     final booking = state.active;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Active Booking')),
//       body: booking == null
//           ? const Center(child: Text('No active booking'))
//           : Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Booking ID: \${booking.id}',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text('Lot: \${booking.lotId}'),
//                     const SizedBox(height: 8),
//                     Text('Status: \${booking.status}'),
//                     const SizedBox(height: 8),
//                     Text(
//                         'Start: \${DateFormat.yMMMd().add_jm().format(booking.startTime)}'),
//                     Text(
//                         'End: \${DateFormat.yMMMd().add_jm().format(booking.endTime)}'),
//                     const SizedBox(height: 16),
//                     Row(children: [
//                       ElevatedButton(
//                           onPressed: () {
//                             final newEnd = booking.endTime
//                                 .add(const Duration(minutes: 30));
//                             ref.read(bookingProvider.notifier).createBooking(
//                                 userId: booking.userId,
//                                 lotId: booking.lotId,
//                                 spotId: booking.spotId,
//                                 start: booking.startTime,
//                                 end: newEnd);
//                           },
//                           child: const Text('Extend +30m')),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                           onPressed: () => ref
//                               .read(bookingProvider.notifier)
//                               .cancelBooking(booking.id),
//                           child: const Text('Cancel')),
//                     ]),
//                     const Spacer(),
//                     ElevatedButton(
//                         onPressed: () => Navigator.pushNamed(context, '/home'),
//                         child: const Text('Back to Home')),
//                   ]),
//             ),
//     );
//   }
// }

// lib/features/booking/active_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import 'package:intl/intl.dart';

class ActiveBookingScreen extends ConsumerWidget {
  const ActiveBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);
    final booking = state.active;
    return Scaffold(
      appBar: AppBar(title: const Text('Active Booking')),
      body: booking == null
          ? const Center(child: Text('No active booking'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.lastEventMessage != null) ...[
                      Card(
                        color: Colors.yellow[50],
                        child: ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(state.lastEventMessage!),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text('Booking ID: ${booking.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Lot: ${booking.lotId}'),
                    const SizedBox(height: 8),
                    Text('Status: ${booking.status}'),
                    const SizedBox(height: 8),
                    Text(
                        'Start: ${DateFormat.yMMMd().add_jm().format(booking.startTime)}'),
                    Text(
                        'End: ${DateFormat.yMMMd().add_jm().format(booking.endTime)}'),
                    const SizedBox(height: 16),
                    Row(children: [
                      ElevatedButton(
                          onPressed: () {
                            // Extend by 30 seconds for demo (represents +30m)
                            final newEnd = booking.endTime
                                .add(const Duration(seconds: 30));
                            ref.read(bookingProvider.notifier).createBooking(
                                userId: booking.userId,
                                lotId: booking.lotId,
                                spotId: booking.spotId,
                                start: booking.startTime,
                                end: newEnd);
                          },
                          child: const Text('Extend +30s')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () => ref
                              .read(bookingProvider.notifier)
                              .cancelBooking(booking.id),
                          child: const Text('Cancel')),
                    ]),
                    const SizedBox(height: 12),
                    if (booking.status == 'REASSIGNED') ...[
                      Card(
                        color: Colors.blue[50],
                        child: ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: const Text(
                              'You have been re-assigned to another lot'),
                          subtitle: Text(
                              'New lot: ${booking.lotId}\nSpot: ${booking.spotId ?? "buffer spot"}'),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            TextButton(
                                onPressed: () => ref
                                    .read(bookingProvider.notifier)
                                    .acceptReassignment(),
                                child: const Text('Accept')),
                            TextButton(
                                onPressed: () => ref
                                    .read(bookingProvider.notifier)
                                    .declineReassignment(),
                                child: const Text('Decline')),
                          ]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Manual "simulate overstay now" button for demo: this will trigger the same behavior as SimulationService
                        // In prototype we simulate by calling the internal handler in provider via a fake event:
                        // We emulate by calling cancel then re-create? Simpler: show info to user.
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Overstay simulation: wait for automatic behavior (demo).')));
                      },
                      child:
                          const Text('Simulate Overstay (automatic happens)'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/home'),
                        child: const Text('Back to Home')),
                  ]),
            ),
    );
  }
}
