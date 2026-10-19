import 'package:flutter/material.dart';
import 'package:naseej/core/constant/app_colors.dart';
import 'package:naseej/core/constant/linkapi.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/auth/otp_verification_page.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'package:naseej/l10n/app_localizations.dart';
class EmailVerificationNotification extends StatefulWidget {
  final String email;

  const EmailVerificationNotification({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailVerificationNotification> createState() =>
      _EmailVerificationNotificationState();
}

class _EmailVerificationNotificationState
    extends State<EmailVerificationNotification> {
  final Crud _crud = Crud();
  bool _isResending = false;

  Future<void> _resendVerificationCode() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isResending = true;
    });

    var response = await _crud.postRequest(AppLink.resendOTP, {
      "email": widget.email,
      "type": "signup",
    });

    setState(() {
      _isResending = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.verificationCodeResentSuccessfully),
          backgroundColor: AppColor.successColor,
        ),
      );
    } else {
      String errorMessage = response["message"] ?? AppLocalizations.of(context)!.failedToResendCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            errorMessage,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColor.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SizedBox(height: 40),

              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 60,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 32),

              // Title
              Text(
                AppLocalizations.of(context)!.verificationEmailSent,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              // Description
              Text(
                AppLocalizations.of(context)!.verificationEmailDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8),

              // Email display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email_outlined, color: AppColor.primaryColor),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Instructions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.borderGray),
                ),
                child: Column(
                  children: [
                    _buildInstruction(
                      icon: Icons.check_circle_outline,
                      text: AppLocalizations.of(context)!.checkInboxInstruction,
                      color: AppColor.successColor,
                    ),
                    SizedBox(height: 12),
                    _buildInstruction(
                      icon: Icons.schedule_outlined,
                      text: AppLocalizations.of(context)!.codeExpiresIn30Min,
                      color: AppColor.goldAccent,
                    ),
                    SizedBox(height: 12),
                    _buildInstruction(
                      icon: Icons.warning_amber_outlined,
                      text: AppLocalizations.of(context)!.checkSpamFolder,
                      color: AppColor.warningColor,
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Continue Button
              Button(
                title: AppLocalizations.of(context)!.enterVerificationCode,
                onpressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OTPVerificationPage(email: widget.email),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),

              // Resend option
              TextButton(
                onPressed: _isResending ? null : _resendVerificationCode,
                child: _isResending
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColor,
                    ),
                  ),
                )
                    : Text(
                  AppLocalizations.of(context)!.didntReceiveCodeResend,
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey2,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}