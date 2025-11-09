import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget { const ProfileScreen({Key? key}): super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: Text('Profile (Prototype)')));
  }
}
class BookingsScreen extends StatelessWidget { const BookingsScreen({Key? key}): super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Bookings')), body: const Center(child: Text('Bookings history (Prototype)')));
  }
}
class AdminScreen extends StatelessWidget { const AdminScreen({Key? key}): super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Admin')), body: const Center(child: Text('Admin tools (Prototype)')));
  }
}
class PaymentsScreen extends StatelessWidget { const PaymentsScreen({Key? key}): super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Payments')), body: const Center(child: Text('Payments (Prototype)')));
  }
}
class SettingsScreen extends StatelessWidget { const SettingsScreen({Key? key}): super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: const Center(child: Text('Settings & Help (Prototype)')));
  }
}
