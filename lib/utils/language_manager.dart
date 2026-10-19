import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naseej/l10n/app_localizations.dart';

class LanguageManager {
  static late SharedPreferences _prefs;

  /// Single global key for language — not user-specific.
  /// Language is a device-level preference that persists across logins.
  static const String _languageKey = 'app_selected_language';

  /// Key to track whether the user has ever explicitly chosen a language
  static const String _hasChosenKey = 'app_language_chosen_by_user';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _initDefaultLanguage();
  }

  /// On first launch only, detect the device language and save it.
  /// After that, always use the saved preference.
  static void _initDefaultLanguage() {
    if (!_prefs.containsKey(_languageKey)) {
      // First launch: save device language as default
      final deviceLang = _getDeviceLanguageCode();
      _prefs.setString(_languageKey, deviceLang);
      // Mark that the user has NOT explicitly chosen — it's auto-detected
      _prefs.setBool(_hasChosenKey, false);
    }
  }

  /// Returns the device's default locale language code (ar or en)
  static String _getDeviceLanguageCode() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final code = deviceLocale.languageCode;
    if (code == 'ar') return 'ar';
    return 'en';
  }

  /// Get the current locale as a Locale object
  static Locale getCurrentLocale() {
    return Locale(getCurrentLanguageCode());
  }

  /// Save the user's language choice
  static Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
    await _prefs.setBool(_hasChosenKey, true);
  }

  /// Get the saved language code (always returns saved value after init)
  static String getCurrentLanguageCode() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  static bool isArabic() {
    return getCurrentLanguageCode() == 'ar';
  }

  static bool isEnglish() {
    return getCurrentLanguageCode() == 'en';
  }

  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    ];
  }

  /// Convenience method to get AppLocalizations from context
  static AppLocalizations tr(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}