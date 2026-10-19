import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej/core/services/ProfileService.dart';

class DeleteAccountController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool isLoading = false;
  String errorMessage = '';

  Future<bool> deleteAccount() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final success = await _profileService.deleteAccount();

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

final deleteAccountProvider =
    ChangeNotifierProvider.autoDispose<DeleteAccountController>((ref) {
  return DeleteAccountController();
});