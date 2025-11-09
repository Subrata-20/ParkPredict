class Booking {
  final String id;
  final String userId;
  final String lotId;
  final String? spotId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int priceCents;

  Booking(
      {required this.id,
      required this.userId,
      required this.lotId,
      this.spotId,
      required this.startTime,
      required this.endTime,
      required this.status,
      required this.priceCents});
}
