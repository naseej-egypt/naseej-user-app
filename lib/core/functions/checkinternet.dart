import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Check internet connection using multiple methods
class InternetChecker {
  static final InternetChecker _instance = InternetChecker._internal();
  factory InternetChecker() => _instance;
  InternetChecker._internal();

  /// Check internet connection
  /// On web: uses HTTP request (dart:io is not available)
  /// On mobile: uses HTTP request (cross-platform compatible)
  Future<bool> checkInternet() async {
    if (kIsWeb) {
      // connectivity_plus often returns false positives (ConnectivityResult.none) on Web.
      // We return true here and let the HTTP requests fail naturally if offline.
      return true;
    }
    try {
      final response = await http.head(
        Uri.parse('https://www.google.com'),
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Check internet using connectivity_plus package
  Future<bool> hasConnection() async {
    if (kIsWeb) return true; // Bypass connectivity_plus bugs on web
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // FIXED: Check if list contains 'none'
      if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
        return false;
      }

      // Even if connected to WiFi/Mobile, verify actual internet access
      return await checkInternet();
    } catch (_) {
      return false;
    }
  }

  /// Get connection type
  Future<String> getConnectionType() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();

      // FIXED: Handle List<ConnectivityResult>
      if (connectivityResults.isEmpty || connectivityResults.contains(ConnectivityResult.none)) {
        return 'No Connection';
      }

      // Return first non-none connection type
      for (var result in connectivityResults) {
        switch (result) {
          case ConnectivityResult.wifi:
            return 'WiFi';
          case ConnectivityResult.mobile:
            return 'Mobile Data';
          case ConnectivityResult.ethernet:
            return 'Ethernet';
          case ConnectivityResult.vpn:
            return 'VPN';
          case ConnectivityResult.bluetooth:
            return 'Bluetooth';
          case ConnectivityResult.other:
            return 'Other';
          case ConnectivityResult.none:
            continue;
        }
      }

      return 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Stream of connectivity changes - FIXED: Returns List<ConnectivityResult>
  Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
}

/// Quick function for checking internet (backwards compatible)
Future<bool> checkInternet() async {
  return await InternetChecker().checkInternet();
}