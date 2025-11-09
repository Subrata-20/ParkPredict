// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/providers/map_provider.dart';
// import '../../widgets/lot_card.dart';

// class MapScreen extends ConsumerStatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends ConsumerState<MapScreen> {
//   @override
//   void initState() {
//     super.initState();
//     ref.read(mapProvider.notifier).loadLots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(mapProvider);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Map - Prototype')),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
//               child: Stack(
//                 children: [
//                   GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 8),
//                     itemBuilder: (context, idx) => Container(
//                         decoration: BoxDecoration(
//                             border: Border.all(color: Color(0xFFECEFF1)))),
//                     itemCount: 8 * 12,
//                   ),
//                   Positioned.fill(
//                     child: LayoutBuilder(builder: (context, constraints) {
//                       final w = constraints.maxWidth;
//                       final h = constraints.maxHeight;
//                       final markers = <Widget>[];
//                       final lots = state.lots;
//                       for (var i = 0; i < lots.length; i++) {
//                         final lot = lots[i];
//                         final dx = (0.12 + 0.2 * i) * w;
//                         final dy = (0.2 + 0.18 * i) * h;
//                         markers.add(Positioned(
//                           left: dx.clamp(8.0, w - 64),
//                           top: dy.clamp(8.0, h - 64),
//                           child: GestureDetector(
//                             onTap: () => Navigator.pushNamed(context, '/lot',
//                                 arguments: lot),
//                             child: Column(
//                               children: [
//                                 Container(
//                                     padding: const EdgeInsets.all(6),
//                                     decoration: BoxDecoration(
//                                         color: Colors.indigo,
//                                         shape: BoxShape.circle),
//                                     child: const Icon(Icons.local_parking,
//                                         color: Colors.white, size: 18)),
//                                 const SizedBox(height: 4),
//                                 Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 6, vertical: 4),
//                                     decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(6),
//                                         boxShadow: [
//                                           BoxShadow(
//                                               color: Colors.black12,
//                                               blurRadius: 4)
//                                         ]),
//                                     child: Text('\${lot.available} free',
//                                         style: const TextStyle(fontSize: 12)))
//                               ],
//                             ),
//                           ),
//                         ));
//                       }
//                       return Stack(children: markers);
//                     }),
//                   ),
//                   if (state.loading)
//                     const Center(child: CircularProgressIndicator()),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 160,
//             child: state.error != null
//                 ? Center(child: Text('Error: \${state.error}'))
//                 : ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: state.lots.length,
//                     itemBuilder: (context, idx) => SizedBox(
//                         width: 300, child: LotCard(lot: state.lots[idx])),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/map_provider.dart';
import '../../widgets/lot_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Load parking lots from FakeApi when screen opens
    Future.microtask(() => ref.read(mapProvider.notifier).loadLots());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Map - Prototype')),
      body: Column(
        children: [
          // -------- Mock Map Area --------
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Stack(
                children: [
                  // Background grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemCount: 8 * 12,
                    itemBuilder: (context, _) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                    ),
                  ),

                  // Markers for each lot
                  if (state.lots.isNotEmpty)
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = constraints.maxHeight;
                          final markers = <Widget>[];

                          for (var i = 0; i < state.lots.length; i++) {
                            final lot = state.lots[i];
                            final dx = (0.1 + 0.25 * (i % 3)) * w;
                            final dy = (0.15 + 0.25 * (i ~/ 3)) * h;
                            markers.add(Positioned(
                              left: dx.clamp(8.0, w - 64),
                              top: dy.clamp(8.0, h - 64),
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/lot',
                                    arguments: lot),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.indigo,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.local_parking,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: Text(
                                        '${lot.available} free',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                          }
                          return Stack(children: markers);
                        },
                      ),
                    ),

                  // Loading indicator
                  if (state.loading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.indigo),
                    ),
                ],
              ),
            ),
          ),

          // -------- Bottom Horizontal List of Lots --------
          SizedBox(
            height: 160,
            child: state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.lots.length,
                    itemBuilder: (context, idx) => SizedBox(
                      width: 300,
                      child: LotCard(lot: state.lots[idx]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
