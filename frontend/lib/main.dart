import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/map/map_screen.dart';
import 'features/lot/lot_detail_screen.dart';
import 'features/booking/booking_confirm_screen.dart';
import 'features/booking/active_booking_screen.dart';
import 'features/home/stub_screens.dart';

void main() {
  runApp(const ProviderScope(child: ParkPredictApp()));
}

class ParkPredictApp extends StatelessWidget {
  const ParkPredictApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPredict (Prototype)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/map': (_) => const MapScreen(),
        '/lot': (_) => const LotDetailScreen(),
        '/confirm': (_) => const BookingConfirmScreen(),
        '/active': (_) => const ActiveBookingScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/bookings': (_) => const BookingsScreen(),
        '/admin': (_) => const AdminScreen(),
        '/payments': (_) => const PaymentsScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
