import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHandler {

  /// Check if user is within a specified radius (in meters) from a target location.
  static Future<bool?> isWithinRadius({
    required BuildContext context,
    required double targetLatitude,
    required double targetLongitude,
    required double radiusInMeters,
  }) async {
    try {
      final userPosition = await getCurrentLocation(context);
      if (userPosition == null) return null;

      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetLatitude,
        targetLongitude,
      );

      return distance <= radiusInMeters;
    } catch (e) {
      print("Error checking radius: $e");
      return null;
    }
  }


  static Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog(context);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showPermissionDialog(context);
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog(context);
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Location permission is required to access your current position. "
              "Please enable it in app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  static void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Service Disabled"),
        content: const Text(
          "Location services are disabled. Please enable them to proceed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static void showOutOfRadiusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Out of Range",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "You are not within the required radius of the target location.",
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

}
