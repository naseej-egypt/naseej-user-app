import 'package:flutter/material.dart';
import 'package:naseej/auth/login.dart';
import 'package:naseej/auth/register.dart';
import 'package:naseej/pages/change_password_screen.dart';
import 'package:naseej/pages/main_container.dart';
import 'package:naseej/pages/terms_consent_page.dart';
import 'package:naseej/onboarding/onboarding.dart';
import 'package:naseej/pages/shop_page.dart';
import 'package:naseej/pages/orders_page.dart';
import 'package:naseej/pages/stores_page.dart';

import 'auth/email_verification_notification.dart';
import 'auth/forget_password_email.dart';
import 'auth/forget_password_otp.dart';
import 'auth/otp_verification_page.dart';
import 'auth/reset_password.dart';

/// Standard Flutter named routes map
final Map<String, WidgetBuilder> routes = {
  // Onboarding route
  "/onboarding": (context) => const OnBoarding(),

  // Terms & Privacy consent (shown after onboarding, before login)
  "/terms-consent": (context) => const TermsConsentPage(),

  // Auth routes
  "/login": (context) => const login(),
  "/register": (context) => const register(),

  // Main container with bottom navigation - starts at Home (index 2)
  "/main": (context) => const MainContainer(initialIndex: 2),
  "/home": (context) => const MainContainer(initialIndex: 2), // Alias for backwards compatibility

  // Direct page access
  "/shop": (context) => const ShopPage(category: 'All'),
  "/orders": (context) => const OrdersPage(),
  "/stores": (context) => StoresPage(),

  // Verification routes
  "/email-verification": (context) => EmailVerificationNotification(email: ''),
  "/otp-verification": (context) => OTPVerificationPage(email: ''),

  // Password recovery routes
  "/forget-password-email": (context) => ForgetPasswordEmailPage(),
  "/forget-password-otp": (context) => ForgetPasswordOTPPage(email: ''),
  "/reset-password": (context) => ResetPasswordPage(email: '', verificationCode: ''),

  // Cart route
  "/cart": (context) => const MainContainer(initialIndex: 3),

  // Settings / Account
  "/change-password": (context) => const ChangePasswordScreen(),
};

/// Route generator handling arguments safely
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;

  switch (settings.name) {
    case '/email-verification':
      final email = (args is Map && args['email'] != null)
          ? args['email'] as String
          : (args is String ? args : '');
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => EmailVerificationNotification(email: email),
      );

    case '/otp-verification':
      final email = (args is Map && args['email'] != null)
          ? args['email'] as String
          : (args is String ? args : '');
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => OTPVerificationPage(email: email),
      );

    case '/forget-password-otp':
      final email = (args is Map && args['email'] != null)
          ? args['email'] as String
          : (args is String ? args : '');
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ForgetPasswordOTPPage(email: email),
      );

    case '/reset-password':
      String email = '';
      String code = '';
      if (args is Map) {
        email = args['email']?.toString() ?? '';
        code = args['verificationCode']?.toString() ?? args['code']?.toString() ?? '';
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ResetPasswordPage(email: email, verificationCode: code),
      );

    default:
      final builder = routes[settings.name];
      if (builder != null) {
        return MaterialPageRoute(settings: settings, builder: builder);
      }
      return null;
  }
}