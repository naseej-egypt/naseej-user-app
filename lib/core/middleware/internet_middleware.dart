import 'package:flutter/material.dart';
import 'package:naseej/core/functions/checkinternet.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/l10n/app_localizations.dart';

/// Show no internet dialog
void showNoInternetDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WiFi off icon with animation
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: AppColor.warningColor,
                ),
              ),

              SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)!.noInternetConnection,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 12),

              Text(
                AppLocalizations.of(context)!.checkInternetAndRetry,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColor.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(color: AppColor.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        bool hasInternet = await checkInternet();
                        if (!hasInternet) {
                          showNoInternetDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.retry),
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
}

/// Show no internet snackbar
void showNoInternetSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No internet connection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: AppColor.warningColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.retry,
        textColor: Colors.white,
        onPressed: () async {
          bool hasInternet = await checkInternet();
          if (hasInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.white),
                    SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!.connectedToInternet),
                  ],
                ),
                backgroundColor: AppColor.successColor,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    ),
  );
}