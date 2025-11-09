// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/models/lot.dart';
// import '../../core/services/fake_api.dart';
// import '../../core/models/spot.dart';

// class LotDetailScreen extends ConsumerStatefulWidget {
//   const LotDetailScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
// }

// class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
//   Lot? lot;
//   List<Spot> spots = [];
//   bool loading = false;
//   String? error;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)!.settings.arguments;
//     if (args is Lot) {
//       lot = args;
//       _loadSpots();
//     }
//   }

//   Future<void> _loadSpots() async {
//     if (lot == null) return;
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       spots = await FakeApi.getSpots(lot!.id);
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (lot == null)
//       return Scaffold(
//           appBar: AppBar(title: const Text('Lot')),
//           body: const Center(child: Text('No lot selected')));
//     return Scaffold(
//       appBar: AppBar(title: Text(lot!.name)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(lot!.address, style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 8),
//           Row(children: [
//             Text('Availability: \${lot!.available}/\${lot!.totalSpots}'),
//             const SizedBox(width: 12),
//             Chip(label: Text('₹\${lot!.pricePerHour}/hr'))
//           ]),
//           const SizedBox(height: 12),
//           Text('Spots',
//               style:
//                   const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           if (loading)
//             const Center(child: CircularProgressIndicator())
//           else if (error != null)
//             Center(child: Text('Error: \$error'))
//           else
//             ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: spots.length,
//                 separatorBuilder: (_, __) => const Divider(),
//                 itemBuilder: (context, idx) {
//                   final s = spots[idx];
//                   return ListTile(
//                     title: Text(s.label),
//                     subtitle: Text(
//                         "Type: \${s.types.join(', ')} - Status: \${s.status}"),
//                     trailing: ElevatedButton(
//                       onPressed: s.status == 'free'
//                           ? () => Navigator.pushNamed(context, '/confirm',
//                               arguments: {'lot': lot, 'spot': s})
//                           : null,
//                       child: const Text('Book'),
//                     ),
//                   );
//                 })
//         ]),
//       ),
//     );
//   }
// }

// lib/features/lot/lot_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/lot.dart';
import '../../core/services/fake_api.dart';
import '../../core/models/spot.dart';
import '../../core/providers/prediction_provider.dart';

class LotDetailScreen extends ConsumerStatefulWidget {
  const LotDetailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  Lot? lot;
  List<Spot> spots = [];
  bool loading = false;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Lot) {
      lot = args;
      _loadSpots();
    }
  }

  Future<void> _loadSpots() async {
    if (lot == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      spots = await FakeApi.getSpots(lot!.id);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _forceOccupy() async {
    if (lot == null) return;
    // For demo: force the lot to 0 available to demonstrate zero-inventory flows
    await FakeApi.forceOccupy(lot!.id, 99);
    final updated = await FakeApi.getLotById(lot!.id);
    if (updated != null) {
      setState(() {
        lot = updated;
      });
    }
    // reload spots
    await _loadSpots();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Force-occupied for demo (lot now likely full).')));
  }

  @override
  Widget build(BuildContext context) {
    final predictor = ref.watch(predictionProvider);
    final p = (lot != null) ? predictor.predictAvailability(lot!) : 0.0;
    return Scaffold(
      appBar: AppBar(title: Text(lot?.name ?? 'Lot')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lot?.address ?? '',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text(
                              'Availability: ${lot?.available}/${lot?.totalSpots}'),
                          const SizedBox(width: 12),
                          Chip(label: Text('₹${lot?.pricePerHour}/hr'))
                        ]),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: p, minHeight: 8),
                        const SizedBox(height: 6),
                        Text(
                            'Predicted availability: ${(p * 100).toStringAsFixed(0)}%'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/confirm',
                                arguments: {'lot': lot, 'spot': null}),
                            child: const Text('Book this lot')),
                        const SizedBox(height: 8),
                        ElevatedButton(
                            onPressed: _forceOccupy,
                            child: const Text('Force-occupy (demo)')),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Spots',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: spots.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, idx) {
                              final s = spots[idx];
                              return ListTile(
                                title: Text(s.label),
                                subtitle: Text(
                                    'Type: ${s.types.join(', ')} - Status: ${s.status}'),
                                trailing: ElevatedButton(
                                  onPressed: s.status == 'free'
                                      ? () => Navigator.pushNamed(
                                          context, '/confirm',
                                          arguments: {'lot': lot, 'spot': s})
                                      : null,
                                  child: const Text('Book'),
                                ),
                              );
                            })
                      ]),
                ),
    );
  }
}
