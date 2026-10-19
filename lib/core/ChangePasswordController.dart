import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej/core/services/ProfileService.dart';

class ChangePasswordController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool isLoading = false;
  String errorMessage = '';

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final success = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = '';
    notifyListeners();
  }
}

final changePasswordProvider =
    ChangeNotifierProvider.autoDispose<ChangePasswordController>((ref) {
  return ChangePasswordController();
});