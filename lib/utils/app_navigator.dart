import 'package:flutter/material.dart';

/// Clean navigation and dialog utility replacing GetX context-free navigation.
/// Uses standard Flutter Navigator and ScaffoldMessenger keys.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to named route (like Get.toNamed)
  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with named route (like Get.offNamed)
  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Clear stack and push named route (like Get.offAllNamed)
  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route (like Get.back)
  static void back<T extends Object?>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Display a snackbar
  static void showSnackBar(
    String message, {
    String? title,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty) ...[
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.white,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message,
              style: TextStyle(color: textColor ?? Colors.white),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF323232),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
