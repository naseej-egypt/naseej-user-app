import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/utils/session_manager.dart';
import 'package:naseej/utils/app_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naseej/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naseej/l10n/app_localizations.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();

  // Initialize managers
  await LanguageManager.initialize();
  await ThemeManager.initialize();
  await FavoritesManager.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _validateSessionOnStartup();
  }

  void _loadUserPreferences() {
    // Load saved language (on first launch = device language, after = user choice)
    final languageCode = LanguageManager.getCurrentLanguageCode();
    _locale = Locale(languageCode);

    // Load saved theme
    _themeMode = ThemeManager.getThemeMode();

    setState(() {});
  }

  /// Validate session after the first frame renders.
  /// If the session is expired, the user is silently redirected to login.
  void _validateSessionOnStartup() {
    final userId = sharedPref.getString('user_id');
    if (userId == null || userId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isValid = await SessionManager.validateCurrentSession();
      if (!isValid) {
        await SessionManager.handleSessionExpiry();
      }
    });
  }

  void changeLanguage(String languageCode) async {
    await LanguageManager.setLanguage(languageCode);
    final newLocale = Locale(languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  void changeTheme(ThemeMode themeMode) async {
    await ThemeManager.setThemeMode(themeMode);
    setState(() {
      _themeMode = themeMode;
    });
  }

  // Check if user has completed onboarding
  String _getInitialRoute() {
    String? step = sharedPref.getString("step");
    String? userId = sharedPref.getString("user_id");
    bool termsAccepted = sharedPref.getBool('terms_accepted') ?? false;

    // If user is logged in, go to home
    if (userId != null && userId.isNotEmpty) {
      // Initialize user-specific settings (theme, favorites — NOT language)
      ThemeManager.setCurrentUser(userId);
      FavoritesManager.setCurrentUser(userId);
      return "/main";
    }

    // If onboarding completed
    if (step == "1") {
      // Check if terms have been accepted
      if (!termsAccepted) {
        return "/terms-consent";
      }
      return "/login";
    }

    // Otherwise, show onboarding
    return "/onboarding";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naseej App',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.messengerKey,

      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],

      // Current locale — always from saved preference, NOT system
      locale: _locale,

      // Theme configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,

      // Routes
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      initialRoute: _getInitialRoute(),
    );
  }
}