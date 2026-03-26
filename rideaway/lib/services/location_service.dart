import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns a human-readable location string (GPS coordinates).
  /// Returns null if permission is denied or location unavailable.
  Future<String?> getCurrentLocationString() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied.');
        return null;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final lat = position.latitude.toStringAsFixed(6);
      final lng = position.longitude.toStringAsFixed(6);
      return 'Lat: $lat, Lng: $lng';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Returns a Google Maps URL for the current position.
  Future<String?> getCurrentLocationUrl() async {
    final locationStr = await getCurrentLocationString();
    if (locationStr == null) return null;

    // Parse back to create a Maps URL
    final parts = locationStr.replaceAll('Lat: ', '').replaceAll('Lng: ', '').split(', ');
    if (parts.length == 2) {
      return 'https://maps.google.com/?q=${parts[0]},${parts[1]}';
    }
    return null;
  }
}
