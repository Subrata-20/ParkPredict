import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<bool> requestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<LocationData?> getLocation() async {
    try {
      final ok = await requestPermission();
      if (!ok) return null;
      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }
}