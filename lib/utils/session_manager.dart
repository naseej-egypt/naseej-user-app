import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:naseej/utils/app_navigator.dart';
import 'package:http/http.dart' as http;
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/main.dart';

/// Centralized session management utility.
/// Detects expired sessions and forces logout + navigation to login.
class SessionManager {
  static bool _isHandlingExpiry = false;

  /// Check if a server response indicates an expired/invalid session.
  static bool isSessionExpired(Map<String, dynamic> response) {
    if (response['status'] != 'fail' && response['status'] != 'error') {
      return false;
    }

    final message = (response['message'] ?? '').toString().toLowerCase();
    return message.contains('session') ||
        message.contains('login again') ||
        message.contains('authentication required') ||
        message.contains('please login') ||
        message.contains('unauthorized');
  }

  /// Handle session expiry: clear user data and redirect to login.
  /// Uses a guard flag to prevent multiple simultaneous redirects.
  static Future<void> handleSessionExpiry() async {
    // Prevent re-entrant calls (e.g. multiple API calls failing at once)
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;

    try {
      // Clear all user-related data from SharedPreferences
      await _clearUserData();

      // Navigate to login, removing all routes from the stack
      AppNavigator.offAllNamed('/login');
    } catch (e) {
      debugPrint('SessionManager: Error during session expiry handling: $e');
    } finally {
      // Reset the guard after a short delay to allow navigation to settle
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingExpiry = false;
      });
    }
  }

  /// Clear all user session data from SharedPreferences.
  static Future<void> _clearUserData() async {
    await sharedPref.remove('user_id');
    await sharedPref.remove('user_email');
    await sharedPref.remove('user_name');
    await sharedPref.remove('user_phone');
    await sharedPref.remove('token');
    await sharedPref.remove('step');
  }

  /// Validate the current session against the server.
  /// Returns true if valid, false if expired/invalid.
  static Future<bool> validateCurrentSession() async {
    final token = sharedPref.getString('token');
    final userId = sharedPref.getString('user_id');

    // No token or user ID means no session to validate
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(AppLink.validateSession),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint('SessionManager: Session validation error: $e');
      // On network error, don't force logout — give benefit of doubt
      return true;
    }
  }
}
