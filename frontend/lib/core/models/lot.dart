class Lot {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int totalSpots;
  final int available;
  final double pricePerHour;

  Lot({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.totalSpots,
    required this.available,
    required this.pricePerHour,
  });
}
