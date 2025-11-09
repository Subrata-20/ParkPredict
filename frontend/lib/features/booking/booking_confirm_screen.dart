// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/models/lot.dart';
// import '../../core/models/spot.dart';
// import '../../core/providers/booking_provider.dart';
// import 'package:intl/intl.dart';

// class BookingConfirmScreen extends ConsumerStatefulWidget {
//   const BookingConfirmScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<BookingConfirmScreen> createState() =>
//       _BookingConfirmScreenState();
// }

// class _BookingConfirmScreenState extends ConsumerState<BookingConfirmScreen> {
//   Lot? lot;
//   Spot? spot;
//   DateTime start = DateTime.now();
//   DateTime end = DateTime.now().add(const Duration(hours: 1));
//   bool loading = false;
//   String? error;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)!.settings.arguments as Map?;
//     if (args != null) {
//       lot = args['lot'] as Lot?;
//       spot = args['spot'] as Spot?;
//     }
//   }

//   Future<void> _confirm() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       await ref.read(bookingProvider.notifier).createBooking(
//           userId: 'user-demo',
//           lotId: lot!.id,
//           spotId: spot?.id,
//           start: start,
//           end: end);
//       final b = ref.read(bookingProvider).active;
//       if (b != null) {
//         Navigator.pushNamedAndRemoveUntil(context, '/active', (r) => false);
//       } else {
//         setState(() => error = 'Booking failed');
//       }
//     } catch (e) {
//       setState(() => error = e.toString());
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final df = DateFormat.yMMMd().add_jm();
//     return Scaffold(
//       appBar: AppBar(title: const Text('Confirm Booking')),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(lot?.name ?? '',
//               style:
//                   const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           if (spot != null) Text('Spot: \${spot!.label}'),
//           const SizedBox(height: 12),
//           Text('Start: \${df.format(start)}'),
//           Text('End: \${df.format(end)}'),
//           const SizedBox(height: 12),
//           Row(children: [
//             ElevatedButton(
//                 onPressed: () async {
//                   final res = await showDatePicker(
//                       context: context,
//                       initialDate: start,
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime.now().add(const Duration(days: 7)));
//                   if (res != null)
//                     setState(() => start = DateTime(res.year, res.month,
//                         res.day, start.hour, start.minute));
//                 },
//                 child: const Text('Change Start')),
//             const SizedBox(width: 8),
//             ElevatedButton(
//                 onPressed: () async {
//                   final res = await showDatePicker(
//                       context: context,
//                       initialDate: end,
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime.now().add(const Duration(days: 7)));
//                   if (res != null)
//                     setState(() => end = DateTime(
//                         res.year, res.month, res.day, end.hour, end.minute));
//                 },
//                 child: const Text('Change End')),
//           ]),
//           const Spacer(),
//           if (error != null)
//             Text('Error: \$error', style: const TextStyle(color: Colors.red)),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//                 onPressed: loading ? null : _confirm,
//                 child: loading
//                     ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                     : const Text('Confirm & Pay (Demo)')),
//           )
//         ]),
//       ),
//     );
//   }
// }

// lib/features/booking/booking_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/lot.dart';
import '../../core/models/spot.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/services/fake_api.dart';
import 'package:intl/intl.dart';

class BookingConfirmScreen extends ConsumerStatefulWidget {
  const BookingConfirmScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends ConsumerState<BookingConfirmScreen> {
  Lot? lot;
  Spot? spot;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now().add(const Duration(hours: 1));
  bool loading = false;
  String? error;
  List<Lot> alternatives = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      lot = args['lot'] as Lot?;
      spot = args['spot'] as Spot?;
      // scale short demo durations: for prototype we show short waits so UI flows quickly
      start = DateTime.now();
      end = DateTime.now().add(const Duration(minutes: 1)); // short
      _loadAlternatives();
    }
  }

  Future<void> _loadAlternatives() async {
    if (lot == null) return;
    alternatives =
        await ref.read(bookingProvider.notifier).suggestAlternatives(lot!.id);
    setState(() {});
  }

  Future<void> _confirm() async {
    if (lot == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ref.read(bookingProvider.notifier).createBooking(
          userId: 'demo-user',
          lotId: lot!.id,
          spotId: spot?.id,
          start: start,
          end: end);
      final st = ref.read(bookingProvider);
      // if waitlist -> show dialog offering alternatives
      if (st.active != null && st.active!.status == 'WAITLIST') {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('No spots available'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                      'This lot has no free spots now. You have been added to the waitlist. Here are nearby options:'),
                  const SizedBox(height: 8),
                  ...alternatives.take(3).map((a) => ListTile(
                        title: Text(a.name),
                        subtitle:
                            Text('${a.available} free • ₹${a.pricePerHour}/hr'),
                        onTap: () {
                          Navigator.pop(ctx);
                          // user chooses an alternative -> open confirm screen for that lot
                          Navigator.pushReplacementNamed(context, '/confirm',
                              arguments: {'lot': a, 'spot': null});
                        },
                      )),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close')),
                ],
              );
            });
        setState(() {
          loading = false;
        });
        return;
      }

      // On successful confirm (status CONFIRMED) navigate to active booking screen
      if (st.active != null && st.active!.status == 'CONFIRMED') {
        Navigator.pushNamedAndRemoveUntil(context, '/active', (r) => false);
      } else {
        setState(() {
          error = 'Booking failed';
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd().add_jm();
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lot?.name ?? '',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (spot != null) Text('Spot: ${spot!.label}'),
          const SizedBox(height: 12),
          Text('Start: ${df.format(start)}'),
          Text('End: ${df.format(end)}'),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(
                onPressed: () async {
                  final res = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 7)));
                  if (res != null)
                    setState(() => start = DateTime(res.year, res.month,
                        res.day, start.hour, start.minute));
                },
                child: const Text('Change Start')),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () async {
                  final res = await showDatePicker(
                      context: context,
                      initialDate: end,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 7)));
                  if (res != null)
                    setState(() => end = DateTime(
                        res.year, res.month, res.day, end.hour, end.minute));
                },
                child: const Text('Change End')),
          ]),
          const SizedBox(height: 12),
          if (alternatives.isNotEmpty) ...[
            const Text('Suggested alternatives:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: alternatives.length,
                itemBuilder: (context, idx) {
                  final a = alternatives[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${a.available} free • ₹${a.pricePerHour}/hr'),
                            const Spacer(),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/confirm',
                                      arguments: {'lot': a, 'spot': null});
                                },
                                child: const Text('Book this')),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ],
          const Spacer(),
          if (error != null)
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: loading ? null : _confirm,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm & Pay (Demo)')),
          )
        ]),
      ),
    );
  }
}
