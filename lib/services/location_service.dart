import 'package:location/location.dart';

class LocationService {
  static final _location = Location();

  static bool _isServiceEnabled = false;
  static PermissionStatus _permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;
  static Future<void> init() async {
    await _cheService();
    await _checkPermission();

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      interval: 1000,
    );
  }

  static Future<void> _cheService() async {
    _isServiceEnabled = await _location.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();

      if (!_isServiceEnabled) {
        return; // Redirect to Settings - Sozlamalardan to'g'irlash kerak endi
      }
    }
  }

  static Future<void> _checkPermission() async {
    _permissionStatus = await _location.hasPermission();

    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return; // Sozlamalardan to'g'irlash kerak (ruxsat berish kerak)
      }
    }
  }

  static Future<LocationData> getCurrentLocation() async {
    // if (_isServiceEnabled && _permissionStatus == PermissionStatus.granted) {
    return currentLocation = await _location.getLocation();
    // }
  }

  static Stream<LocationData> getLiveLocation() async* {
    yield* _location.onLocationChanged;
  }
}
