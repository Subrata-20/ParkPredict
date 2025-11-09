class Spot {
  final String id;
  final String label;
  final List<String> types;
  final bool isActive;
  final String status; // free | occupied | reserved

  Spot(
      {required this.id,
      required this.label,
      required this.types,
      required this.isActive,
      required this.status});
}
