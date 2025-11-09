import 'package:flutter/material.dart';
import '../core/models/lot.dart';

class LotCard extends StatelessWidget {
  final Lot lot;
  const LotCard({Key? key, required this.lot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.indigo, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.local_parking, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(lot.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(lot.address,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Row(children: [
                  Chip(label: Text('\${lot.available} free')),
                  const SizedBox(width: 8),
                  Text('₹\${lot.pricePerHour}/hr',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ])
              ])),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/lot', arguments: lot),
              child: const Text('View'))
        ]),
      ),
    );
  }
}
