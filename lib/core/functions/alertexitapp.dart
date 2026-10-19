import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:naseej/utils/app_navigator.dart';

/// Show exit confirmation dialog with app theme styling
Future<bool> alertExitApp(BuildContext context) async {
  // On web, there's no concept of "exit app" — just ignore
  if (kIsWeb) return Future.value(false);

  final isDark = Theme.of(context).brightness == Brightness.dark;

  bool? shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Color(0xFF2C2520), Color(0xFF1A1614)]
                  : [Colors.white, AppColor.backgroundcolor.withOpacity(0.5)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.2),
                      AppColor.secondColor.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 48,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 20),

              // Title
              Text(
                "Exit App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),

              SizedBox(height: 12),

              // Message
              Text(
                "Are you sure you want to exit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColor.backgroundcolor : AppColor.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColor.primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Exit Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primaryColor,
                            AppColor.secondColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "yes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (shouldExit == true) {
    SystemNavigator.pop();
  }

  return Future.value(false);
}

/// Show exit confirmation dialog (Alternative method using AppNavigator context)
Future<bool> alertExitAppGetX() {
  if (kIsWeb) return Future.value(false);
  final ctx = AppNavigator.context;
  if (ctx != null) {
    return alertExitApp(ctx);
  }
  return Future.value(false);
}