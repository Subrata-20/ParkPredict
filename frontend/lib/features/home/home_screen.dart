// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/providers/auth_provider.dart';
// import 'dart:math';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchCtrl = TextEditingController();
//   late final AnimationController _anim;
//   @override
//   void initState() {
//     super.initState();
//     _anim = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 700))
//       ..forward();
//   }

//   @override
//   void dispose() {
//     _anim.dispose();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   Widget _greeting(String? userId) {
//     final name = (userId == null) ? 'Driver' : 'Driver';
//     return Row(
//       children: [
//         Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text('Good day,', style: TextStyle(color: Colors.grey[700])),
//           const SizedBox(height: 6),
//           Text(name,
//               style:
//                   const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//         ])),
//         CircleAvatar(
//             backgroundColor: Colors.indigo[50],
//             child: const Icon(Icons.person, color: Colors.indigo)),
//       ],
//     );
//   }

//   void _openQuickBook() {
//     Navigator.pushNamed(context, '/map');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final cards = [
//       _CardData('Map', 'Find nearby parking', Icons.map, ['/map']),
//       _CardData(
//           'Active', 'Your current booking', Icons.local_parking, ['/active']),
//       _CardData('Quick Book', 'Reserve quickly', Icons.flash_on, ['/map']),
//       _CardData('Bookings', 'History & receipts', Icons.history, ['/bookings']),
//       _CardData('Profile', 'Account & settings', Icons.person, ['/profile']),
//       _CardData(
//           'Admin', 'Partner tools', Icons.admin_panel_settings, ['/admin']),
//       _CardData(
//           'Payments', 'Manage payment methods', Icons.payment, ['/payments']),
//       _CardData('Help', 'Support & FAQ', Icons.help_outline, ['/settings']),
//     ];
//     return Scaffold(
//       appBar: AppBar(title: const Text('ParkPredict')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _greeting(auth.userId),
//               const SizedBox(height: 12),
//               Material(
//                 elevation: 2,
//                 borderRadius: BorderRadius.circular(10),
//                 child: TextField(
//                   controller: _searchCtrl,
//                   decoration: InputDecoration(
//                       prefixIcon: const Icon(Icons.search),
//                       hintText: 'Search parking, lot or address',
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 56,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _ActionChip('Map', Icons.map,
//                         () => Navigator.pushNamed(context, '/map')),
//                     const SizedBox(width: 8),
//                     _ActionChip(
//                         'Quick', Icons.flash_on, () => _openQuickBook()),
//                     const SizedBox(width: 8),
//                     _ActionChip('Active', Icons.access_time,
//                         () => Navigator.pushNamed(context, '/active')),
//                     const SizedBox(width: 8),
//                     _ActionChip('Bookings', Icons.history,
//                         () => Navigator.pushNamed(context, '/bookings')),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Expanded(
//                 child: GridView.builder(
//                   itemCount: cards.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisExtent: 140,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12),
//                   itemBuilder: (context, idx) {
//                     final c = cards[idx];
//                     final angle = Tween(begin: 0.9, end: 1.0).animate(
//                         CurvedAnimation(
//                             parent: _anim,
//                             curve: Interval(min(1, idx * 0.05), 1.0,
//                                 curve: Curves.easeOut)));
//                     return ScaleTransition(
//                       scale: angle,
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(context, c.routeList.first);
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: [
//                                 Colors.indigo,
//                                 Colors.indigo.shade300
//                               ]),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 6,
//                                     offset: const Offset(0, 4))
//                               ]),
//                           padding: const EdgeInsets.all(14),
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 CircleAvatar(
//                                     backgroundColor:
//                                         Colors.white.withOpacity(0.4),
//                                     child: Icon(c.icon, color: Colors.white)),
//                                 const SizedBox(height: 12),
//                                 Text(c.title,
//                                     style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(height: 6),
//                                 Text(c.subtitle,
//                                     style: const TextStyle(
//                                         color: Colors.white70, fontSize: 12)),
//                               ]),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CardData {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final List<String> routeList;
//   _CardData(this.title, this.subtitle, this.icon, this.routeList);
// }

// Widget _ActionChip(String label, IconData icon, VoidCallback onTap) {
//   return ActionChip(
//       label: Text(label),
//       avatar: CircleAvatar(child: Icon(icon, size: 16)),
//       onPressed: onTap,
//       elevation: 2,
//       backgroundColor: Colors.white);
// }

// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/booking_provider.dart';
import 'dart:math';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _greeting(String? userId) {
    final name = (userId == null) ? 'Driver' : 'Driver';
    return Row(
      children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good day,', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text(name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ])),
        Stack(
          children: [
            CircleAvatar(
                backgroundColor: Colors.indigo[50],
                child: const Icon(Icons.person, color: Colors.indigo)),
            // show small dot if there's a recent event
          ],
        ),
      ],
    );
  }

  void _openQuickBook() {
    Navigator.pushNamed(context, '/map');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final bookingState = ref.watch(bookingProvider);
    final hasNotification = (bookingState.lastEventMessage != null &&
        bookingState.lastEventMessage!.isNotEmpty);
    final cards = [
      _CardData('Map', 'Find nearby parking', Icons.map, ['/map']),
      _CardData(
          'Active', 'Your current booking', Icons.local_parking, ['/active']),
      _CardData('Quick Book', 'Reserve quickly', Icons.flash_on, ['/map']),
      _CardData('Bookings', 'History & receipts', Icons.history, ['/bookings']),
      _CardData('Profile', 'Account & settings', Icons.person, ['/profile']),
      _CardData(
          'Admin', 'Partner tools', Icons.admin_panel_settings, ['/admin']),
      _CardData(
          'Payments', 'Manage payment methods', Icons.payment, ['/payments']),
      _CardData('Help', 'Support & FAQ', Icons.help_outline, ['/settings']),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkPredict'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (hasNotification)
                  Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle))),
              ],
            ),
            onPressed: () {
              final msg = bookingState.lastEventMessage ?? 'No notifications';
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: const Text('Notifications'),
                          content: Text(msg),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'))
                          ]));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _greeting(auth.userId),
              const SizedBox(height: 12),
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search parking, lot or address',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ActionChip('Map', Icons.map,
                        () => Navigator.pushNamed(context, '/map')),
                    const SizedBox(width: 8),
                    _ActionChip(
                        'Quick', Icons.flash_on, () => _openQuickBook()),
                    const SizedBox(width: 8),
                    _ActionChip('Active', Icons.access_time,
                        () => Navigator.pushNamed(context, '/active')),
                    const SizedBox(width: 8),
                    _ActionChip('Bookings', Icons.history,
                        () => Navigator.pushNamed(context, '/bookings')),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  itemCount: cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 140,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemBuilder: (context, idx) {
                    final c = cards[idx];
                    final angle = Tween(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(
                            parent: _anim,
                            curve: Interval((idx * 0.05).clamp(0.0, 1.0), 1.0,
                                curve: Curves.easeOut)));
                    return ScaleTransition(
                      scale: angle,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, c.routeList.first);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.indigo,
                                Colors.indigo.shade300
                              ]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4))
                              ]),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.4),
                                    child: Icon(c.icon, color: Colors.white)),
                                const SizedBox(height: 12),
                                Text(c.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(c.subtitle,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> routeList;
  _CardData(this.title, this.subtitle, this.icon, this.routeList);
}

Widget _ActionChip(String label, IconData icon, VoidCallback onTap) {
  return ActionChip(
      label: Text(label),
      avatar: CircleAvatar(child: Icon(icon, size: 16)),
      onPressed: onTap,
      elevation: 2,
      backgroundColor: Colors.white);
}
